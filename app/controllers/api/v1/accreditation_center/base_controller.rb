require 'auth_token/auth_token_decryptor'

module Api
  module V1
    module AccreditationCenter
      class BaseController < ActionController::API
        before_action :check_feature_enabled, :check_ip_whitelist, :authenticate_user

        rescue_from ActiveRecord::RecordNotFound, with: :show_not_found_error
        rescue_from ActiveRecord::RecordInvalid, with: :show_invalid_record_error
        rescue_from ArgumentError, with: :show_argument_error
        rescue_from(ActionController::ParameterMissing) do |parameter_missing_exception|
          render_error("Parameter #{parameter_missing_exception.param} is required", :unprocessable_entity)
        end
        rescue_from StandardError, with: :show_standard_error

        private

        def check_feature_enabled
          return if Feature.allow_accr_endspoints?

          render_error('Accreditation Center API is not allowed', :forbidden)
        end

        def show_not_found_error
          render_error('Not found', :not_found)
        end

        def show_invalid_record_error(exception)
          render_error(exception.record.errors.full_messages.join(', '), :bad_request)
        end

        def show_argument_error(exception)
          render_error(exception.message, :bad_request)
        end

        def show_standard_error(exception)
          render_error(exception.message, :internal_server_error)
        end

        def authenticate_user
          username, password = Base64.strict_decode64(basic_token).split(':')
          @current_user ||= ApiUser.find_by(username: username, plain_text_password: password)
          return if @current_user

          raise(ArgumentError)
        rescue NoMethodError, ArgumentError
          render_error('Invalid authorization information', :unauthorized)
        end

        def basic_token
          pattern = /^Basic /
          header  = request.headers['Authorization']
          header = header.gsub(pattern, '') if header&.match(pattern)
          header.strip
        end

        def render_error(message, status)
          render json: { message: message }, status: status
        end

        def render_success(message: nil, data: nil)
          @response = { message: message || 'Command completed successfully',
                        data: data || {} }

          render(json: @response, status: :ok)
        end

        def check_ip_whitelist
          Rails.logger.debug "[check_ip_whitelist] Request IP: #{request.ip}"
          return if ip_allowed?(request.ip) || Rails.env.development?

          render_error("IP address #{request.ip} is not authorized", :unauthorized)
        end

        def ip_allowed?(ip)
          allowed_ips = ENV['accreditation_center_allowed_ips'].to_s.split(',').map(&:strip)
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
end
