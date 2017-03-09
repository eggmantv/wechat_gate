require 'rest-client'
require 'wechat_gate/request'

module WechatGate
  module Oauth
    #
    #
    # 此module中的access_token是微信网页授权OAuth2.0的专用access_token，和其他modules中所需需要的access_token
    # 不是一个概念，这里的access_token主要就是用户非公众号的关注用户来进行网页授权访问的，其中：
    #   scope:
    #     snsapi_base 用于公众号已关注用户，已关注的用户默认已经得到了授权，这里只是为了取得当前用户的openid，
    #       此时对用户的所有操作 (ex: WechatGate::User模块) 可以直接利用系统基本的access_token (WechatGate::Tokens::AccessToken模块) 来进行。
    #     snsapi_userinfo 用户非关注用户取得授权，这里遵循标准的OAuth2.0授权流程，取得用户信息需要利用本模块中的方法来进行。
    #       这里的access_token是和用户绑定的。
    #
    #

    #
    # 用户点击授权入口页面
    #
    def oauth2_entrance_url(ops = {})
      ops = {
        state: 'empty', # 自定义参数值
        redirect_uri: self.specs["oauth2_redirect_uri"],
        scope: 'snsapi_base' # snsapi_base | snsapi_userinfo
      }.merge(ops)

      "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{self.specs['app_id']}&redirect_uri=#{CGI.escape(ops[:redirect_uri])}&response_type=code&scope=#{ops[:scope]}&state=#{ops[:state]}#wechat_redirect"
    end

    # TODO
    #   这里目前需要调用该gem的应用自身来保存用户的access_token, refresh_token, openid等参数以及判断有效期
    #   不过这个地方也可以不做缓存，微信在这个地方没有限制API的调用次数。
    #
    # code:
    #   code来源于网页端redirect_uri页面得到的微信端返回的参数，专门用户取得下一步的access_token
    # 该接口会返回：
    # {
    #    "access_token" => "access_token",
    #    "expires_in"=>7200,
    #    "refresh_token"=>"refresh_token",
    #    "openid"=>"MZkwG5sAx-d4PMQ6Lq1xisE",
    #    "scope"=>"snsapi_base"
    #  }
    # 此时已经获得了用户的openid，如果用户为公众号的订阅用户，就可以直接利用Tokens::AccessToken的token来对改用户调用业务接口了，
    # 此时这里的access_token意义就不大了，这里的access_token和Tokens::AccessToken的token是完全不一样的。
    #
    def oauth2_access_token(code)
      WechatGate::Request.send("https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{self.specs['app_id']}&secret=#{self.specs['app_secret']}&code=#{code}&grant_type=authorization_code")
    end

    # access_token拥有较短的有效期，当access_token超时后，可以使用refresh_token进行刷新，
    # refresh_token拥有较长的有效期（7天、30天、60天、90天），当refresh_token失效的后，需要用户重新授权。
    #
    def oauth2_access_token_valid?(access_token, openid)
      WechatGate::Request.send("https://api.weixin.qq.com/sns/auth?access_token=#{access_token}&openid=#{openid}")
    end

    # 利用refresh_token刷新access_token
    #
    # response:
    # {
    #    "access_token":"ACCESS_TOKEN",
    #    "expires_in":7200,
    #    "refresh_token":"REFRESH_TOKEN",
    #    "openid":"OPENID",
    #    "scope":"SCOPE"
    # }
    def oauth2_refresh_access_token(refresh_token)
      WechatGate::Request.send("https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=#{self.specs['app_id']}&grant_type=refresh_token&refresh_token=#{refresh_token}")
    end

    # 获取用户信息
    #
    def oauth2_user(access_token, openid)
      WechatGate::Request.send("https://api.weixin.qq.com/sns/userinfo?access_token=#{access_token}&openid=#{openid}&lang=zh_CN")
    end
  end

end
