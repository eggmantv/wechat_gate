require 'wechat_gate/request'

module WechatGate
  module Media
    #
    # http://mp.weixin.qq.com/wiki/15/8386c11b7bc4cdd1499c572bfe2e95b3.html
    #

    #   type: image | video | voice | news (图文)
    def medias(type = 'news', offset = 0, count = 20)
      WechatGate::Request.send(
        "https://api.weixin.qq.com/cgi-bin/material/batchget_material?access_token=#{self.access_token}",
        :post,
        {
          "type": type,
          "offset": offset,
          "count": count
        }.to_json
      )
    end
  end


end
