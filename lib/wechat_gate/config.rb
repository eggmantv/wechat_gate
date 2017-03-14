require 'yaml'
require 'erb'
require 'wechat_gate/tokens/access_token'
require 'wechat_gate/tokens/jsapi_ticket'
require 'wechat_gate/tokens/ext'
require 'wechat_gate/oauth'
require 'wechat_gate/user'
require 'wechat_gate/menu'
require 'wechat_gate/media'
require 'wechat_gate/message'
require 'wechat_gate/send_message'
require 'wechat_gate/exception'
require 'wechat_gate/controller'

module WechatGate
  class Config

    attr_reader :app_name
    attr_reader :config
    attr_reader :output_type

    include WechatGate::Tokens::AccessToken
    include WechatGate::Tokens::JsapiTicket
    include WechatGate::Tokens::Ext
    include WechatGate::Oauth
    include WechatGate::User
    include WechatGate::Menu
    include WechatGate::Media
    include WechatGate::Message
    include WechatGate::SendMessage

    def initialize app_name, config_file = nil
      unless config_file
        if defined?(Rails)
          config_file = "#{Rails.root}/config/wechat.yml"
        end
      end

      raise Exception::ConfigException, "no wechat configuration file found!" unless config_file
      unless File.exists?(config_file)
        raise Exception::ConfigException, "configuration file does not exist!"
      end

      config_text = ERB.new(File.read(config_file)).result
      configs = YAML.load(config_text)
      unless configs[app_name]
        raise Exception::ConfigException, "no configuration found for app: #{app_name}!"
      end

      @config = if defined?(Rails)
        configs[app_name][Rails.env] || configs[app_name]
      else
        configs[app_name]
      end

      @app_name = app_name

      yield(self) if block_given?
    end

  end


end
