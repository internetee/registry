require 'serializers/repp/domain'

module Api
  module V1
    module AccreditationCenter
      class DomainsController < BaseController
        api :GET, 'api/v1/accreditation_center/domains/:name'
        desc 'get domain by name'
        def show
          @domain = Domain.find_by(name: params[:name])

          if @domain
            render_success(data: { domain: Serializers::Repp::Domain.new(@domain, sponsored: true).to_json })
          else
            render_error('Domain not found', :not_found)
          end
        end
      end
    end
  end
end
