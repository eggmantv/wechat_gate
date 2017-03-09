require 'rest-client'

module WechatGate
  module Request
    def self.send(url, method = :get, payload = nil, headers = nil, &block)
      method = method.to_sym

      opts = {
        method: method,
        url: url,
        verify_ssl: false
      }
      if method == :post and payload
        opts.merge! payload: payload
      end

      if headers
        opts.merge! headers: headers
      end

      response = RestClient::Request.execute(opts)
      response = JSON.parse(response)
      raise response.to_s if response['errmsg'] and response['errmsg'] != 'ok'

      if block_given?
        yield(response)
      else
        response
      end
    end
  end


end
