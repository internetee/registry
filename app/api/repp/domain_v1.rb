module Repp
  class DomainV1 < Grape::API
    version 'v1', using: :path

    resource :domains do
      desc 'Return list of domains'
      params do
        optional :limit, type: Integer, values: (1..200).to_a, desc: 'How many domains to show'
        optional :offset, type: Integer, desc: 'Domain number to start at'
        optional :details, type: String, values: %w(true false), desc: 'Whether to include details'
      end

      get '/' do
        limit = params[:limit] || 200
        offset = params[:offset] || 0

        if params[:details] == 'true'
          domains = current_user.registrar.domains.limit(limit).offset(offset)
        else
          domains = current_user.registrar.domains.limit(limit).offset(offset).pluck(:name)
        end

        @response = {
          domains: domains,
          total_number_of_records: current_user.registrar.domains.count
        }
      end
    end
  end
end
