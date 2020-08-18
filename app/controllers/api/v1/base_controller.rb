module Api
  module V1
    class BaseController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :not_found_error

      private

      def authenticate
        ip_allowed = allowed_ips.include?(request.remote_ip)
        head :unauthorized unless ip_allowed
      end

      def not_found_error
        uuid = params['uuid']
        json = { error: 'Not Found', uuid: uuid, message: 'Record not found' }
        render json: json, status: :not_found
      end

      def allowed_ips
        ENV['auction_api_allowed_ips'].split(',').map(&:strip)
      end
    end
  end
end
