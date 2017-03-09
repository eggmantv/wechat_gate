require 'wechat_gate/tokens/base'

module WechatGate
  module Tokens
    module JsapiTicket
      def self.included base
        base.send :include, InstanceMethods
      end

      module InstanceMethods
        def jsapi_ticket
          token = WechatGate::Tokens::JsapiTicket::Get.refresh(self)
        end
      end

      class Get < WechatGate::Tokens::Base
        def url
          token = WechatGate::Tokens::AccessToken::Get.refresh(@config)
          "https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token=#{token}&type=jsapi"
        end

        def save response
          File.open(saved_file, 'w') do |f|
            f.puts "#{Time.now.to_i} #{response['ticket']}"
          end
        end
      end
    end

  end
end
