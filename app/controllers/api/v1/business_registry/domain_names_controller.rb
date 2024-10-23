module Api
  module V1
    module BusinessRegistry
      class DomainNamesController < ::Api::V1::BusinessRegistry::BaseController
        before_action :authenticate, only: [:show]
        skip_before_action :find_reserved_domain, only: [:show]
        
        include Concerns::CorsHeaders
        
        before_action :validate_organization_name

        def show
          name = params[:organization_name]
          all_variants = ::BusinessRegistry::DomainNameGeneratorService.generate(name)
          available_variants = ::BusinessRegistry::DomainAvailabilityCheckerService.filter_available(all_variants)
          render json: { variants: available_variants }, status: :ok
        end

        private

        def validate_organization_name
          name = params[:organization_name]
          if name.blank? || name.length > 100 || !name.match?(/\A[\p{L}\p{N}\s\-]+\z/)
            render json: { error: 'Invalid organization name' }, status: :bad_request
          end
        end
      end
    end
  end
end
