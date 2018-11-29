require 'rails5_api_controller_backport'

module Api
  module V1
    class BaseController < ActionController::API
      private

      def authenticate
        ip_allowed = allowed_ips.include?(request.remote_ip)
        head :unauthorized unless ip_allowed
      end

      def allowed_ips
        ENV['auction_api_allowed_ips'].split(',').map(&:strip)
      end
    end
  end
end
