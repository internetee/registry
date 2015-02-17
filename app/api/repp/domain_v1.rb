module Repp
  class DomainV1 < Grape::API
    version 'v1', using: :path

    resource :domains do
      desc 'Return list of domains'
      get '/' do
        domains = current_user.registrar.domains.page(params[:page])
        @response = {
          domains: domains,
          total_pages: domains.total_pages
        }
      end
    end
  end
end
