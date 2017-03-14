require 'rest-client'
require 'wechat_gate/request'

module WechatGate
  module Tokens
    class Base

      def self.refresh config
        handler = new(config)
        handler.run
      end

      def initialize config
        @config = config
      end

      def run
        fetch if is_expired?
        File.readlines(saved_file).first.chomp.split(' ').last
      end

      def expired_in
        7100
      end

      protected
      def url
        raise "need to implement #ur method in sub-class"
      end

      def save response
        raise "need to implement #save method in sub-class"
      end

      private
      def fetch
        WechatGate::Request.send(url) do |response|
          save response
          response
        end
      end

      def saved_file
        # File.expand_path("../../../../data/APP-#{@config.app_name}-#{self.class.name}", __FILE__)
        "/tmp/APP-#{@config.app_name}-#{self.class.name}-#{@config.config['app_id']}"
      end

      def is_expired?
        if File.exists?(saved_file)
          line = File.readlines(saved_file).first
          unless line
            return true
          else
            line = line.chomp
            return Time.now.to_i - line.split(' ').first.to_i >= expired_in
          end
        else
          FileUtils.touch(saved_file)
          return true
        end
      end

    end

  end
end
