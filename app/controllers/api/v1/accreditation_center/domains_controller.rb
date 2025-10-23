require 'serializers/repp/domain'

module Api
  module V1
    module AccreditationCenter
      class DomainsController < BaseController
        def show
          @domain = Domain.find_by(name: params[:name])

          if @domain
            render json: { code: 1000, domain: Serializers::Repp::Domain.new(@domain,
                                                                             sponsored: true).to_json },
                   status: :ok
          else
            render json: { errors: 'Domain not found' }, status: :not_found
          end
        end
      end
    end
  end
end
