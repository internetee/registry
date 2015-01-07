module Repp
  class API < Grape::API
    format :json
    prefix :repp
    version 'v1', using: :path

    http_basic do |username, password|
      @current_user ||= EppUser.find_by(username: username, password: password)
    end

    helpers do
      attr_reader :current_user
    end

    resource :domains do
      desc 'Return list of domains'
      get '/' do
        domains = current_user.registrar.domains.page(params[:page])
        {
          domains: domains,
          total_pages: domains.total_pages
        }
      end
    end
  end
end
