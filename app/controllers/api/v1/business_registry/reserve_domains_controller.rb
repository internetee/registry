module Api
  module V1
    module BusinessRegistry
      class ReserveDomainsController < BaseController
        before_action :authenticate, only: [:create]
        skip_before_action :find_reserved_domain, only: [:create]
        before_action :validate_params

        def create
          domain_names = params[:domain_names]
          result = ReservedDomain.reserve_domains_without_payment(domain_names)

          if result.success
            render_success({ 
              message: "Domains reserved successfully", 
              reserved_domains: result.reserved_domains.map { |domain| { name: domain.name, password: domain.password } }
            }, :created)
          else
            render_error(result.errors, :unprocessable_entity)
          end
        end

        private

        def validate_params
          domain_names = params[:domain_names]
          
          if domain_names.blank? || !domain_names.is_a?(Array)
            render_error("Invalid parameter: domain_names must be a non-empty array of valid domain names", :bad_request)
            return
          end
        
          if domain_names.count > ReservedDomain::MAX_DOMAIN_NAME_PER_REQUEST
            render_error("The maximum number of domain names per request is #{ReservedDomain::MAX_DOMAIN_NAME_PER_REQUEST}", :unprocessable_entity)
            return
          end
        
          if domain_names.any? { |name| name.blank? || !name.match?(/\A[\p{L}\p{N}\-\.]+\z/) }
            render_error("Invalid parameter: domain_names must be a non-empty array of valid domain names", :bad_request)
            return
          end
        end
      end
    end
  end
end
