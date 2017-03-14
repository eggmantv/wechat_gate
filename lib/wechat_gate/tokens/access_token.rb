require 'wechat_gate/tokens/base'

module WechatGate
  module Tokens
    module AccessToken
      def self.included base
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        def access_token
          token = WechatGate::Tokens::AccessToken::Get.refresh(self)
        end
      end

      class Get < WechatGate::Tokens::Base
        def url
          "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{@config.config['app_id']}&secret=#{@config.config['app_secret']}"
        end

        def save response
          File.open(saved_file, 'w') do |f|
            f.puts "#{Time.now.to_i} #{response['access_token']}"
          end
        end
      end

    end
  end
end
