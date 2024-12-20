module Api
  module V1
    module BusinessRegistry
      class DomainNamesController < BaseController
        before_action :validate_organization_name

        def show
          puts "params: #{params[:organization_name]}"
          name = params[:organization_name]
          all_variants = ::BusinessRegistry::DomainNameGeneratorService.generate(name)

          puts "all_variants: #{all_variants.inspect}"
          available_variants = ::BusinessRegistry::DomainAvailabilityCheckerService.filter_available(all_variants)


          puts "available_variants: #{available_variants.inspect}"

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
