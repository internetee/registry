module Repp
  module V1
    class BaseController < ActionController::API # rubocop:disable Metrics/ClassLength
      attr_reader :current_user

      include ErrorAndLogHandler

      before_action :authenticate_user
      before_action :set_locale
      before_action :validate_webclient_ca
      before_action :validate_api_user_cert
      before_action :check_registrar_ip_restriction
      before_action :check_api_ip_restriction
      before_action :set_paper_trail_whodunnit

      private

      def set_domain
        registrar = current_user.registrar
        @domain = Epp::Domain.find_by(registrar: registrar, name: params[:domain_id])
        @domain ||= Epp::Domain.find_by!(registrar: registrar, name_puny: params[:domain_id])

        return @domain if @domain

        raise ActiveRecord::RecordNotFound
      end

      def set_paper_trail_whodunnit
        ::PaperTrail.request.whodunnit = current_user
      end

      def render_success(code: nil, message: nil, data: nil)
        @response = { code: code || 1000, message: message || 'Command completed successfully',
                      data: data || {} }

        render(json: @response, status: :ok)
      end

      def epp_errors
        @epp_errors ||= ActiveModel::Errors.new(self)
      end

      def handle_errors(obj = nil)
        @epp_errors ||= ActiveModel::Errors.new(self)
        if obj
          obj.construct_epp_errors
          obj.errors.each { |error| @epp_errors.import error }
        end

        render_epp_error
      end

      def render_epp_error(status = :bad_request, **data)
        @epp_errors ||= ActiveModel::Errors.new(self)
        @epp_errors.add(:epp_errors, msg: 'Command failed', code: '2304') if data != {}

        error_options = @epp_errors.errors.uniq
                                   .select { |error| error.options[:code].present? }[0].options

        @response = { code: error_options[:code].to_i, message: error_options[:msg], data: data }
        render(json: @response, status: status)
      end

      def handle_non_epp_errors(obj, message = nil)
        @response = { message: message || obj.errors.full_messages.join(', '),
                      data: {} }
        render(json: @response, status: :bad_request)
      end

      def basic_token
        pattern = /^Basic /
        header  = request.headers['Authorization']
        header = header.gsub(pattern, '') if header&.match(pattern)
        header.strip
      end

      def authenticate_user
        username, password = Base64.urlsafe_decode64(basic_token).split(':', 2)
        @current_user ||= ApiUser.find_by(username: username, plain_text_password: password)
        user_active = @current_user.active?

        return if @current_user && user_active

        raise(ArgumentError)
      rescue NoMethodError, ArgumentError
        @response = { code: 2202, message: 'Invalid authorization information',
                      data: { username: username, password: password, active: user_active } }
        render(json: @response, status: :unauthorized)
      end

      def check_api_ip_restriction
        return if webclient_request?
        return if @current_user.registrar.api_ip_white?(request.ip)

        render_unauthorized_ip_response(request.ip)
      end

      def check_registrar_ip_restriction
        return unless webclient_request?

        ip = request.headers['Request-IP']
        return if @current_user.registrar.registrar_ip_white?(ip)

        render_unauthorized_ip_response(ip)
      end

      def render_unauthorized_ip_response(ip)
        @response = { code: 2202, message: I18n.t('registrar.authorization.ip_not_allowed', ip: ip) }
        render json: @response, status: :unauthorized
      end

      def webclient_request?
        return false if Rails.env.test? || Rails.env.development?

        webclient_ips.include?(request.ip)
      end

      def webclient_ips
        ENV['webclient_ips'].to_s.split(',').map(&:strip)
      end

      def validate_webclient_ca
        return unless webclient_request?

        request_name = request.env['HTTP_SSL_CLIENT_S_DN_CN']

        webclient_cn = ENV['webclient_cert_common_name'] || 'webclient'
        return if request_name == webclient_cn

        @response = { code: 2202, message: 'Invalid webclient certificate' }

        render(json: @response, status: :unauthorized)
      end

      def validate_api_user_cert
        return if Rails.env.development? || Rails.env.test?
        return if webclient_request?

        crt = request.env['HTTP_SSL_CLIENT_CERT']
        com = request.env['HTTP_SSL_CLIENT_S_DN_CN']

        return if @current_user.pki_ok?(crt, com)

        render_invalid_cert_response
      end

      def validate_webclient_user_cert
        return if skip_webclient_user_cert_validation?

        crt = request.headers['User-Certificate']
        com = request.headers['User-Certificate-CN']

        Rails.logger.info "--------------------------------"
        Rails.logger.info "Headers: crt=#{crt}, com=#{com}"
        Rails.logger.info "test"
        Rails.logger.info "--------------------------------"

        return if @current_user.pki_ok?(crt, com, api: false)

        Rails.logger.info "-------------------------------- FAIL"
        Rails.logger.info @current_user.pki_ok?(crt, com, api: false)
        Rails.logger.info "-------------------------------- FAIL"

        render_invalid_cert_response
      end

      def render_invalid_cert_response
        @response = { code: 2202, message: 'Invalid user certificate' }
        render(json: @response, status: :unauthorized)
      end

      def skip_webclient_user_cert_validation?
        !webclient_request? || request.headers['Requester'] == 'tara' ||
          Rails.env.development?
      end

      def auth_values_to_data(registrar:)
        data = current_user.as_json(only: %i[id username roles])
        data[:registrar_name] = registrar.name
        data[:legaldoc_mandatory] = registrar.legaldoc_mandatory?
        data[:address_processing] = Contact.address_processing?
        data[:abilities] = Ability.new(current_user).permissions
        data
      end

      def throttled_user
        authorize!(:throttled_user, @domain) unless current_user || action_name == 'tara_callback'
        current_user
      end

      def set_locale
        I18n.locale = current_user&.try(:locale) || params[:locale] || I18n.default_locale
      end
    end
  end
end
