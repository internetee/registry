module Api
  module V1
    module Internal
      # Base controller for the internal, machine-to-machine RDAP data API.
      #
      # Auth (v1 baseline): pre-shared key + IP-allowlist. Modeled on the
      # accreditation_center internal API (IP-allowlist shape) and the
      # api/v1/base_controller authenticate_shared_key pattern. mTLS is a later
      # production-hardening step, not built here. The endpoint is non-public.
      class BaseController < ActionController::API
        before_action :check_ip_whitelist, :authenticate_shared_key

        rescue_from ActiveRecord::RecordNotFound, with: :show_not_found_error
        rescue_from StandardError, with: :show_standard_error

        private

        def authenticate_shared_key
          key = ENV['rdap_internal_api_shared_key'].to_s
          # Fail closed when the key is not configured — never let a blank/unset
          # secret degrade into an "everyone matches Basic " bypass.
          return render_error('Invalid authorization information', :unauthorized) if key.empty?

          expected = "Basic #{key}"
          provided = request.authorization.to_s

          return if ActiveSupport::SecurityUtils.secure_compare(expected, provided)

          render_error('Invalid authorization information', :unauthorized)
        end

        def check_ip_whitelist
          return if ip_allowed?(request.ip) || Rails.env.development?

          render_error("IP address #{request.ip} is not authorized", :unauthorized)
        end

        def ip_allowed?(ip)
          allowed_ips = ENV['rdap_internal_api_allowed_ips'].to_s.split(',').map(&:strip)
          allowed_ips.any? do |entry|
            begin
              IPAddr.new(entry).include?(ip)
            rescue IPAddr::InvalidAddressError
              ip == entry
            end
          end
        end

        def show_not_found_error
          render_error('Not found', :not_found)
        end

        def show_standard_error(exception)
          render_error(exception.message, :internal_server_error)
        end

        def render_error(message, status)
          render json: { message: message }, status: status
        end
      end
    end
  end
end
