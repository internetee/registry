module Repp
  class DomainV1 < Grape::API
    version 'v1', using: :path

    resource :domains do
      desc 'Return list of domains'
      params do
        optional :limit, type: Integer, values: (1..20).to_a
      end

      get '/' do
        limit = params[:limit] || 20

        if params[:details] == 'true'
          domains = current_user.registrar.domains.limit(limit)
        else
          domains = current_user.registrar.domains.limit(limit).pluck(:name)
        end

        @response = {
          domains: domains,
          total_number_of_records: current_user.registrar.domains.count
        }
      end
    end
  end
end
