# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/plugin_mixins/aws_config"
require 'aws-sdk'
require 'timecop'

class DummyInputAwsConfigV2 < LogStash::Inputs::Base
  include LogStash::PluginMixins::AwsConfig::V2

  def aws_service_endpoint(region)
    { :dummy_input_aws_config_region => "#{region}.awswebservice.local" }
  end
end

class DummyInputAwsConfigV2NoRegionMethod < LogStash::Inputs::Base
  include LogStash::PluginMixins::AwsConfig::V2
end

class DummyInputAwsConfigV1 < LogStash::Inputs::Base
  include LogStash::PluginMixins::AwsConfig

  def aws_service_endpoint(region)
    { :dummy_input_aws_config_region => "#{region}.awswebservice.local" }
  end
end

describe LogStash::PluginMixins::AwsConfig do
  let(:settings) { {} }

  subject { DummyInputAwsConfigV1.new(settings).aws_options_hash }

  describe 'config credential' do

    context 'in credential file' do
      let(:settings) { { 'aws_credentials_file' => File.join(File.dirname(__FILE__), '..', 'fixtures/aws_credentials_file_sample_test.yml') } }

      it 'should support reading configuration from a yaml file' do
        expect(subject).to include(:access_key_id => "1234", :secret_access_key => "secret")
      end
    end

    context 'inline' do
      context 'temporary credential' do
        let(:settings) { { 'access_key_id' => '1234', 'secret_access_key' => 'secret', 'session_token' => 'session_token' } }

        it "should support passing as key, value, and session_token" do
          expect(subject[:access_key_id]).to eq(settings["access_key_id"])
          expect(subject[:secret_access_key]).to_not eq(settings["secret_access_key"])
          expect(subject[:secret_access_key].value).to eq(settings["secret_access_key"])
          expect(subject[:session_token]).to_not eq(settings["session_token"])
          expect(subject[:session_token].value).to eq(settings["session_token"])
        end
      end

      context 'normal credential' do
        let(:settings) { { 'access_key_id' => '1234',  'secret_access_key' => 'secret' } }

        it 'should support passing credentials as key, value' do
          expect(subject[:access_key_id]).to eq(settings['access_key_id'])
          expect(subject[:secret_access_key]).to_not eq(settings['secret_access_key'])
          expect(subject[:secret_access_key].value).to eq(settings['secret_access_key'])
        end
      end
    end
  end

  describe 'config region' do
    context 'region provided' do
      let(:settings) { { 'access_key_id' => '1234',  'secret_access_key' => 'secret', 'region' => 'us-west-2' } }

      it 'should use provided region to generate the endpoint configuration' do
        expect(subject[:dummy_input_aws_config_region]).to eq("us-west-2.awswebservice.local")
      end
    end

    context "region not provided" do
      let(:settings) { { 'access_key_id' => '1234',  'secret_access_key' => 'secret'} }

      it 'should use default region to generate the endpoint configuration' do
        expect(subject[:dummy_input_aws_config_region]).to eq("us-east-1.awswebservice.local")
      end
    end
  end

  describe 'config endpoint' do
    context "endpoint provided" do
      let(:settings) { { 'access_key_id' => '1234',  'secret_access_key' => 'secret', 'endpoint' => 'http://localhost'} }

      it 'should use specified endpoint' do
          expect(subject[:endpoint]).to eq("http://localhost")
      end
    end
  end

  context 'when we arent providing credentials' do
    let(:settings) { {} }
    it 'should always return a hash' do
      expect(subject).to eq({ :use_ssl => true, :dummy_input_aws_config_region => "us-east-1.awswebservice.local" })  
    end
  end
end

describe LogStash::PluginMixins::AwsConfig::V2 do
  let(:settings) { {} }

  subject { DummyInputAwsConfigV2.new(settings).aws_options_hash }

  describe 'config credential' do
    subject { DummyInputAwsConfigV2.new(settings).aws_options_hash[:credentials] }

    context 'in credential file' do
      let(:settings) { { 'aws_credentials_file' => File.join(File.dirname(__FILE__), '..', 'fixtures/aws_credentials_file_sample_test.yml') } }

      it 'should support reading configuration from a yaml file' do
        expect(subject.access_key_id).to eq("1234")
        expect(subject.secret_access_key).to eq("secret")   
      end
    end

    context 'inline' do
      context 'temporary credential' do
        let(:settings) { { 'access_key_id' => '1234', 'secret_access_key' => 'secret', 'session_token' => 'session_token' } }

        it "should support passing as key, value, and session_token" do
          expect(subject.access_key_id).to eq(settings['access_key_id'])
          expect(subject.secret_access_key).to eq(settings['secret_access_key'])
          expect(subject.session_token).to eq(settings['session_token'])
        end
      end

      context 'normal credential' do
        let(:settings) { { 'access_key_id' => '1234',  'secret_access_key' => 'secret' } }

        it 'should support passing credentials as key, value' do
          expect(subject.access_key_id).to eq(settings['access_key_id'])
          expect(subject.secret_access_key).to eq(settings['secret_access_key'])
        end
      end

      context 'role arn is provided' do
        let(:settings) { { 'role_arn' => 'arn:aws:iam::012345678910:role/foo', 'region' => 'us-west-2' } }
        let(:sts_double) { instance_double(Aws::STS::Client) }
        let(:now) { Time.now }
        let(:expiration) { Time.at(now.to_i + 3600) }
        let(:temp_credentials) {
          double(credentials:
                  double(
                    access_key_id: '1234',
                    secret_access_key: 'secret',
                    session_token: 'session_token',
                    expiration: expiration.to_s,
                  )
                )
        }
        let(:new_temp_credentials) {
          double(credentials:
                  double(
                    access_key_id: '5678',
                    secret_access_key: 'secret1',
                    session_token: 'session_token1',
                    expiration: expiration.to_s,
                  )
                )
        }

        before do
          allow(Aws::STS::Client).to receive(:new).and_return(sts_double)
          allow(sts_double).to receive(:assume_role)  {
            if Time.now < expiration
              temp_credentials
            else
              new_temp_credentials
            end
          }
        end

        it 'supports passing role_arn' do
          Timecop.freeze(now) do
            expect(subject.credentials.access_key_id).to eq('1234')
            expect(subject.credentials.secret_access_key).to eq('secret')
            expect(subject.credentials.session_token).to eq('session_token')
          end
        end

        it 'rotates the keys once they expire' do
          Timecop.freeze(Time.at(expiration.to_i + 100)) do
            expect(subject.credentials.access_key_id).to eq('5678')
            expect(subject.credentials.secret_access_key).to eq('secret1')
            expect(subject.credentials.session_token).to eq('session_token1')
          end
        end       
      end

      context 'role arn with credentials' do

        let(:settings) do
          {
              'role_arn' => 'arn:aws:iam::012345678910:role/foo',
              'region' => 'us-west-2',

              'access_key_id' => '12345678',
              'secret_access_key' => 'secret',
              'session_token' => 'session_token',

              'proxy_uri' => 'http://a-proxy.net:1234'
          }
        end

        let(:aws_options_hash) { DummyInputAwsConfigV2NoRegionMethod.new(settings).aws_options_hash }

        before do
          allow_any_instance_of(Aws::AssumeRoleCredentials).to receive(:refresh) # called from #initialize
        end

        it 'uses credentials' do
          subject = aws_options_hash[:credentials]
          expect( subject ).to be_a Aws::AssumeRoleCredentials
          expect( subject.client ).to be_a Aws::STS::Client
          expect( credentials = subject.client.config.credentials ).to be_a Aws::Credentials
          expect( credentials.access_key_id ).to eql '12345678'
        end

        it 'sets up proxy on client and region' do
          subject = aws_options_hash[:credentials]
          expect( subject.client.config.http_proxy ).to eql 'http://a-proxy.net:1234'
          expect( subject.client.config.region ).to eql 'us-west-2' # probably redundant (kept for backwards compat)
        end

        it 'sets up region top-level' do
          # NOTE: this one is required for real with role_arn :
          expect( aws_options_hash[:region] ).to eql 'us-west-2'
        end

      end
    end
  end

  describe 'config proxy' do
    let(:proxy) { "http://localhost:1234"  }
    let(:settings) { { 'access_key_id' => '1234',  'secret_access_key' => 'secret', 'region' => 'us-west-2', 'proxy_uri' => proxy } }

    it "should set the http_proxy option" do
      expect(subject[:http_proxy]).to eql(proxy)
    end

    it "should not set the legacy http proxy option" do
      expect(subject[:proxy_uri]).not_to eql(proxy)
    end
  end

  describe 'config region' do
    context "when the class implement `#aws_service_endpoint`" do
      context 'region provided' do
        let(:settings) { { 'access_key_id' => '1234',  'secret_access_key' => 'secret', 'region' => 'us-west-2' } }

        it 'should use provided region to generate the endpoint configuration' do
          expect(subject).to include(:dummy_input_aws_config_region => "us-west-2.awswebservice.local")
        end
      end

      context "region not provided" do
        let(:settings) { { 'access_key_id' => '1234',  'secret_access_key' => 'secret'} }

        it 'should use default region to generate the endpoint configuration' do
          expect(subject).to include(:dummy_input_aws_config_region => "us-east-1.awswebservice.local")
        end
      end
    end

    context "when the classe doesn't implement `#aws_service_endpoint`" do
      subject { DummyInputAwsConfigV2NoRegionMethod.new(settings).aws_options_hash }

      context 'region provided' do
        let(:settings) { { 'access_key_id' => '1234',  'secret_access_key' => 'secret', 'region' => 'us-west-2' } }

        it 'should use provided region to generate the endpoint configuration' do
          expect(subject[:region]).to eq("us-west-2")
        end
      end

      context "region not provided" do
        let(:settings) { { 'access_key_id' => '1234',  'secret_access_key' => 'secret'} }

        it 'should use default region to generate the endpoint configuration' do
          expect(subject[:region]).to eq("us-east-1")
        end
      end
    end
  end

  context 'when we arent providing credentials' do
    let(:settings) { {} }
    it 'should always return a hash' do
      expect(subject).to eq({ :dummy_input_aws_config_region => "us-east-1.awswebservice.local" })  
    end
  end

end
