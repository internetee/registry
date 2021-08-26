require 'serializers/repp/domain'

module Api
  module V1
    module AccreditationCenter
      class DomainsController < ::Api::V1::AccreditationCenter::BaseController
        def show
          @domain = Domain.find_by(name: params[:name])

          if @domain
            render json: { domain: Serializers::Repp::Domain.new(@domain,
                                                                     sponsored: true).to_json  }, status: :found
          else
            render json: { errors: 'Domain not found' }, status: :not_found
          end
        end
      end
    end
  end
end
