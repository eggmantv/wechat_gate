require "wechat_gate/version"
require "wechat_gate/config"

if defined?(ActionController)
  ActionController::Base.send(:include, WechatGate::Controller)
end
