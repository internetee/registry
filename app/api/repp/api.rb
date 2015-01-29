module Repp
  class API < Grape::API
    format :json
    prefix :repp

    http_basic do |username, password|
      @current_api_user ||= ApiUser.find_by(username: username, password: password)
    end

    helpers do
      attr_reader :current_api_user
    end

    after do
      ApiLog::ReppLog.create({
        request_path: request.path,
        request_method: request.request_method,
        request_params: request.params.except('route_info').to_json,
        response: @response.to_json,
        response_code: status,
        api_user_name: current_api_user.try(:username),
        api_user_registrar: current_api_user.try(:registrar).try(:to_s),
        ip: request.ip
      })
    end

    mount Repp::DomainV1
    mount Repp::ContactV1
  end
end
