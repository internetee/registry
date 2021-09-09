module Repp
  module V1
    class BaseController < ActionController::API # rubocop:disable Metrics/ClassLength
      around_action :log_request
      before_action :authenticate_user
      before_action :validate_webclient_ca
      before_action :check_ip_restriction
      attr_reader :current_user

      before_action :set_paper_trail_whodunnit

      private

      def log_request
        yield
      rescue ActiveRecord::RecordNotFound
        @response = { code: 2303, message: 'Object does not exist' }
        render(json: @response, status: :not_found)
      rescue ActionController::ParameterMissing, Apipie::ParamMissing => e
        @response = { code: 2003, message: e.message.gsub(/\n/, '. ') }
        render(json: @response, status: :bad_request)
      rescue Apipie::ParamInvalid => e
        @response = { code: 2005, message: e.message.gsub(/\n/, '. ') }
        render(json: @response, status: :bad_request)
      ensure
        create_repp_log
      end

      # rubocop:disable Metrics/AbcSize
      def create_repp_log
        ApiLog::ReppLog.create(
          request_path: request.path, request_method: request.request_method,
          request_params: request.params.except('route_info').to_json, uuid: request.try(:uuid),
          response: @response.to_json, response_code: response.status, ip: request.ip,
          api_user_name: current_user.try(:username),
          api_user_registrar: current_user.try(:registrar).try(:to_s)
        )
      end
      # rubocop:enable Metrics/AbcSize

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

      def basic_token
        pattern = /^Basic /
        header  = request.headers['Authorization']
        header = header.gsub(pattern, '') if header&.match(pattern)
        header.strip
      end

      def authenticate_user
        username, password = Base64.urlsafe_decode64(basic_token).split(':')
        @current_user ||= ApiUser.find_by(username: username, plain_text_password: password)

        return if @current_user

        raise(ArgumentError)
      rescue NoMethodError, ArgumentError
        @response = { code: 2202, message: 'Invalid authorization information' }
        render(json: @response, status: :unauthorized)
      end

      def check_ip_restriction
        return if webclient_request?
        return if @current_user.registrar.api_ip_white?(request.ip)

        @response = { code: 2202,
                      message: I18n.t('registrar.authorization.ip_not_allowed', ip: request.ip) }
        render(json: @response, status: :unauthorized)
      end

      def webclient_request?
        return if Rails.env.test?

        header  = request.headers['AccreditationToken']
        return if header == ENV['accreditation_secret']

        ENV['webclient_ips'].split(',').map(&:strip).include?(request.ip)
      end

      def validate_webclient_ca
        return unless webclient_request?

        request_name = request.env['HTTP_SSL_CLIENT_S_DN_CN']
        webclient_cn = ENV['webclient_cert_common_name'] || 'webclient'
        return if request_name == webclient_cn

        @response = { code: 2202,
                      message: I18n.t('registrar.authorization.ip_not_allowed', ip: request.ip) }

        render(json: @response, status: :unauthorized)
      end

      def logger
        Rails.logger
      end
    end
  end
end
