module Api
  module V1
    class BaseController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :not_found_error

      private

      def authenticate
        Rails.logger.debug "[authenticate] Request IP: #{request.remote_ip}"
        ip_allowed = ip_allowed?(request.remote_ip)
        head :unauthorized unless ip_allowed
      end

      def authenticate_shared_key
        api_key = "Basic #{ENV['rwhois_internal_api_shared_key']}"
        head(:unauthorized) unless api_key == request.authorization
      end

      def not_found_error
        uuid = params['uuid']
        json = { error: 'Not Found', uuid: uuid, message: 'Record not found' }
        render json: json, status: :not_found
      end

      def ip_allowed?(ip)
        allowed_ips = ENV['auction_api_allowed_ips'].to_s.split(',').map(&:strip)
        allowed_ips.any? do |entry|
          begin
            IPAddr.new(entry).include?(ip)
          rescue IPAddr::InvalidAddressError
            ip == entry
          end
        end
      end
    end
  end
end
