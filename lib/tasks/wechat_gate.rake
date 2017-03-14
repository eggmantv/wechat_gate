require 'wechat_gate/exception'

namespace :wechat_gate do

  def validate_envs
    raise WechatGate::Exception::ConfigException, 'need specify APP_NAME!' unless ENV['APP_NAME']
  end

  desc "create menu, APP_NAME=app_name, CONFIG=/path/to/config/file.yml, MENU=/path/to/menu/config/file.yml"
  task :create_menu => :environment do
    validate_envs

    @config = WechatGate::Config.new(ENV['APP_NAME'], ENV['CONFIG'])

    menu_file = ENV['MENU']
    menu_file = "#{Dir.pwd}/config/wechat_menu.yml" unless menu_file
    raise WechatGate::Exception::ConfigException, "MENU #{menu_file} not found!" unless File.exists?(menu_file)

    menu = YAML.load(ERB.new(File.read(menu_file)).result(binding))
    @config.menu_create(JSON.generate(menu))
  end
end
