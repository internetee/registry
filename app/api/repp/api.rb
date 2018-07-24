module Repp
  class API < Grape::API
    format :json
    prefix :repp

    http_basic do |username, password|
      @current_user ||= ApiUser.find_by(username: username, password: password)
      if @current_user
        true
      else
        error! I18n.t('api_user_not_found'), 401
      end
    end

    before do
      webclient_request = ENV['webclient_ips'].split(',').map(&:strip).include?(request.ip)
      unless webclient_request
        error! I18n.t('api.authorization.ip_not_allowed', ip: request.ip), 401 unless @current_user.registrar.api_ip_white?(request.ip)
      end

      if @current_user.cannot?(:view, :repp)
        error! I18n.t('no_permission'), 401 unless @current_user.registrar.api_ip_white?(request.ip)
      end

      next if Rails.env.test? || Rails.env.development?
      message = 'Certificate mismatch! Cert common name should be:'
      request_name = env['HTTP_SSL_CLIENT_S_DN_CN']

      if webclient_request
        webclient_cert_name = ENV['webclient_cert_common_name'] || 'webclient'
        error! "Webclient #{message} #{webclient_cert_name}", 401 if webclient_cert_name != request_name
      else
        unless @current_user.api_pki_ok?(request.env['HTTP_SSL_CLIENT_CERT'], request.env['HTTP_SSL_CLIENT_S_DN_CN'])
          error! "#{message} #{@current_user.username}", 401
        end
      end
    end

    helpers do
      attr_reader :current_user
    end

    after do
      ApiLog::ReppLog.create({
        request_path: request.path,
        request_method: request.request_method,
        request_params: request.params.except('route_info').to_json,
        response: @response.to_json,
        response_code: status,
        api_user_name: current_user.try(:username),
        api_user_registrar: current_user.try(:registrar).try(:to_s),
        ip: request.ip,
        uuid: request.try(:uuid)
      })
    end

    mount Repp::DomainV1
    mount Repp::ContactV1
    mount Repp::AccountV1
    mount Repp::DomainTransfersV1
    mount Repp::NameserversV1
    mount Repp::DomainContactsV1
  end
end
