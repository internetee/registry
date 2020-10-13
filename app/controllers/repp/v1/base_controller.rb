module Repp
  module V1
    class BaseController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound, with: :not_found_error
      before_action :authenticate_user
      before_action :check_ip_restriction

      attr_reader :current_user

      rescue_from ActionController::ParameterMissing do |exception|
        render json: { code: 2003, message: exception }, status: :bad_request
      end

      private

      def render_success(code: nil, message: nil, data: nil)
        resp = { code: code || 1000, message: message || 'Command completed successfully',
                 data: data || {} }

        render(json: resp, status: :ok)
      end

      def epp_errors
        @epp_errors ||= []
      end

      def handle_errors(obj = nil, update: false)
        @epp_errors ||= []

        obj&.construct_epp_errors
        @epp_errors += obj.errors[:epp_errors] if obj

        format_epp_errors if update
        @epp_errors.uniq!

        render_epp_error
      end

      def format_epp_errors
        @epp_errors.each_with_index do |error, index|
          blocked_by_delete_prohibited?(error, index)
        end
      end

      def blocked_by_delete_prohibited?(error, index)
        if error[:code] == 2304 && error[:value][:val] == DomainStatus::SERVER_DELETE_PROHIBITED &&
           error[:value][:obj] == 'status'

          @epp_errors[index][:value][:val] = DomainStatus::PENDING_UPDATE
        end
      end

      def render_epp_error
        render(
          json: { code: @epp_errors[0][:code], message: @epp_errors[0][:msg] },
          status: :bad_request
        )
      end

      def ip_whitelisted?
        return false unless current_user.registrar.api_ip_white?(request.ip)
      end

      def basic_token
        pattern = /^Basic /
        header  = request.headers['Authorization']
        header.gsub(pattern, '') if header&.match(pattern)
      end

      def authenticate_user
        username, password = Base64.urlsafe_decode64(basic_token).split(':')
        @current_user ||= ApiUser.find_by(username: username, plain_text_password: password)

        return if @current_user

        render(json: { errors: [{ base: ['Not authorized'] }] }, status: :unauthorized)
      end

      def check_ip_restriction
        ip_restriction = Authorization::RestrictedIP.new(request.ip)
        allowed = ip_restriction.can_access_registrar_area?(@current_user.registrar)

        return if allowed

        render(
          status: :unauthorized,
          json: { errors: [
            { base: [I18n.t('registrar.authorization.ip_not_allowed', ip: request.ip)] },
          ] }
        )
      end

      def not_found_error
        render(json: { code: 2303, message: 'Object does not exist' }, status: :not_found)
      end
    end
  end
end
