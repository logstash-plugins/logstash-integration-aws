# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/plugin_mixins/aws_config"
require 'aws-sdk'

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
          expect(subject[:secret_access_key]).to eq(settings["secret_access_key"])
          expect(subject[:session_token]).to eq(settings["session_token"])
        end
      end

      context 'normal credential' do
        let(:settings) { { 'access_key_id' => '1234',  'secret_access_key' => 'secret' } }

        it 'should support passing credentials as key, value' do
          expect(subject[:access_key_id]).to eq(settings['access_key_id'])
          expect(subject[:secret_access_key]).to eq(settings['secret_access_key'])
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
