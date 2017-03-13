module WechatGate
  module Tokens
    module Ext
      # please refer
      #   http://mp.weixin.qq.com/wiki/7/aaa137b55fb2e0456bf8dd9148dd613f.html
      #
      def generate_js_request_params current_page_url
        current_page_url = current_page_url.gsub(/#.*/, '')

        letters = ('a'..'z').to_a + (0..9).to_a
        word_creator = proc { letters.sample }
        noncestr = []
        16.times { noncestr << word_creator.call }

        params = {
          "jsapi_ticket" => self.jsapi_ticket,
          "noncestr" => noncestr.join,
          "timestamp" => Time.now.to_i,
          "url" => current_page_url
        }

        sign_string = params.keys.sort.inject([]) { |m, n| m << "#{n}=#{params[n]}" }.join('&')
        sign = Digest::SHA1.hexdigest(sign_string)
        params["signature"] = sign

        params
      end

      def write_token_to_file current_page_url, output_type
        params = generate_js_request_params(current_page_url)
        case output_type
        when /\// # write to file
          f = File.open(output_type, 'w')
          f.write %Q{<script>var wxServerConfig = #{params.to_json}</script>}
          f.close
        when 'ruby'
          params
        when 'js'
          params.to_json
        else
          params
        end
      end


    end

  end
end
