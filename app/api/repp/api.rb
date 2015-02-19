module Repp
  class API < Grape::API
    format :json
    prefix :repp

    before do
      auth_param = request.headers['Authorization'].split(' ', 2).second
      username, password = ::Base64.decode64(auth_param || '').split(':', 2)

      # allow user lookup only by username if request came from webclient
      if request.ip == APP_CONFIG['webclient_ip'] && password.blank?
        login_params = { username: username }
      else
        login_params = { username: username, password: password }
      end

      @current_user ||= ApiUser.find_by(login_params)
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
        ip: request.ip
      })
    end

    mount Repp::DomainV1
    mount Repp::ContactV1
  end
end
