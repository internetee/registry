module Api
  module V1
    module BusinessRegistry
      class CheckController < ::Api::V1::BaseController
        before_action :set_cors_header
        before_action :validate_organization_name
        before_action :authenticate, only: [:show]

        def show
          name = params[:organization_name]
          all_variants = ::BusinessRegistry::DomainNameGeneratorService.generate(name)
          available_variants = ::BusinessRegistry::DomainAvailabilityChecker.filter_available(all_variants)
          render json: { variants: available_variants }, status: :ok
        end

        private

        def set_cors_header
          allowed_origins = ENV['ALLOWED_ORIGINS'].split(',')
          if allowed_origins.include?(request.headers['Origin'])
            response.headers['Access-Control-Allow-Origin'] = request.headers['Origin']
          else
            render json: { error: "Unauthorized origin" }, status: :unauthorized
          end
        end

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
