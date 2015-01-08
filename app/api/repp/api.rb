module Repp
  class API < Grape::API
    format :json
    prefix :repp

    http_basic do |username, password|
      @current_user ||= EppUser.find_by(username: username, password: password)
    end

    helpers do
      attr_reader :current_user
    end

    mount Repp::DomainV1
    mount Repp::ContactV1
  end
end
