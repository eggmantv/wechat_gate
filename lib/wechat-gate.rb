require "wechat_gate/version"
require "wechat_gate/config"
require "wechat_gate/railtie" if defined?(Rails)

if defined?(ActionController)
  ActionController::Base.send(:include, WechatGate::Controller)
end
