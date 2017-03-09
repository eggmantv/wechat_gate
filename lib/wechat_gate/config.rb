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

module WechatGate
  class Config

    attr_reader :app_config_name
    attr_reader :specs
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

    def initialize app_config_name, config_file = nil
      unless config_file
        if defined?(Rails)
          config_file = "#{Rails.root}/config/wechat.yml"
        end
      end

      raise Exception::ConfigException, "no wechat configuration file found!" unless config_file
      raise Exception::ConfigException, "configuration file does not exist!" unless File.exists?(config_file)

      config_text = ERB.new(File.read(config_file)).result
      configs = YAML.load(config_text)
      @specs = if defined?(Rails)
        configs[app_config_name][Rails.env]
      else
        configs[app_config_name]
      end

      raise "not found app name" unless @specs

      @app_config_name = app_config_name

      yield(self) if block_given?
    end

  end


end
