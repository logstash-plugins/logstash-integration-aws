# encoding: utf-8
require "logstash/plugin_mixins/aws_config/generic"

module LogStash::PluginMixins::AwsConfig::V2
  def self.included(base)
    base.extend(self)
    base.send(:include, LogStash::PluginMixins::AwsConfig::Generic)
  end

  public
  def aws_options_hash
    opts = {}

    if @access_key_id.is_a?(NilClass) ^ @secret_access_key.is_a?(NilClass)
      @logger.warn("Likely config error: Only one of access_key_id or secret_access_key was provided but not both.")
    end

    opts[:credentials] = credentials if credentials

    opts[:http_proxy] = @proxy_uri if @proxy_uri

    if self.respond_to?(:aws_service_endpoint)
      # used by CloudWatch to basically do the same as bellow (returns { region: region })
      opts.merge!(self.aws_service_endpoint(@region))
    else
      # NOTE: setting :region works with the aws sdk (resolves correct endpoint)
      opts[:region] = @region
    end

    if !@endpoint.is_a?(NilClass)
      opts[:endpoint] = @endpoint
    end

    return opts
  end

  private
  def credentials
    @creds ||= begin
                 if @access_key_id && @secret_access_key
                   credentials_opts = {
                     :access_key_id => @access_key_id,
                     :secret_access_key => @secret_access_key.value
                   }

                   credentials_opts[:session_token] = @session_token.value if @session_token
                   Aws::Credentials.new(credentials_opts[:access_key_id],
                                        credentials_opts[:secret_access_key],
                                        credentials_opts[:session_token])
                 elsif @aws_credentials_file
                   credentials_opts = YAML.load_file(@aws_credentials_file)
                   Aws::Credentials.new(credentials_opts[:access_key_id],
                                        credentials_opts[:secret_access_key],
                                        credentials_opts[:session_token])
                 elsif @role_arn
                   assume_role
                 end
               end
  end

  def assume_role
    Aws::AssumeRoleCredentials.new(
      :client => Aws::STS::Client.new(:region => @region),
      :role_arn => @role_arn,
      :role_session_name => @role_session_name
    )
  end
end
