module WechatGate
  require 'rails'

  class Railtie < Rails::Railtie
    rake_tasks { load "tasks/wechat_gate.rake" }
  end

end
