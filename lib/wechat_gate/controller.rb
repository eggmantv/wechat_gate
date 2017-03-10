require 'wechat_gate/exception'

module WechatGate
  module Controller

    def self.included base
      base.send :include, InstanceMethods

      base.class_eval do
        helper_method :is_wechat_logged_in?
        helper_method :current_open_id

        class_attribute :wechat_gate_app_name
      end
    end

    module InstanceMethods
      protected
      def wechat_gate_setup
        unless self.class.wechat_gate_app_name
          raise Exception::ConfigException, "please specify wechat_gate_app_name!"
        end

        @wechat_gate_config = Wechat::Config.new(self.class.wechat_gate_app_name)
      end

      def wechat_gate_config
        @wechat_gate_config ||= wechat_gate_setup
      end

      def is_wechat_logged_in?
        !!session[:user_open_id]
      end

      def current_open_id
        session[:user_open_id]
      end

      def wechat_user_signin(user_open_id)
        session[:user_open_id] = user_open_id
      end

      def wechat_user_auth
        unless is_wechat_logged_in?
          redirect_to wechat_gate_config.oauth2_entrance_url(scope: "snsapi_base")
        end
      end

      def bind_user_with_open_id user_model
        if is_wechat_logged_in? and user_model.open_id.blank?
          user_model.update_attribute :open_id, current_open_id
        end
      end

      def is_legal_from_wechat_server?
        data = [
          wechat_gate_config.specs["push_token"],
          params[:timestamp],
          params[:nonce]
        ]

        Digest::SHA1.hexdigest(data.sort.join('')) == params[:signature]
      end

      def check_wechat_server
        unless is_legal_from_wechat_server?
          render text: "illegal signature!"
        end
      end
    end

  end
end
