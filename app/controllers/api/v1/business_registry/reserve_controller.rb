module Api
  module V1
    module BusinessRegistry
      # DEPRECATED

      class ReserveController < BaseController
        before_action :authenticate, only: [:create]
        skip_before_action :find_reserved_domain, only: [:create]
        before_action :validate_params

        def create
          domain_name = params[:domain_name]&.downcase&.strip
          reserved_domain = ReservedDomain.find_by(name: domain_name)

          if ::BusinessRegistry::DomainAvailabilityCheckerService.is_domain_available?(domain_name)
            reserve_new_domain(domain_name)
          else
            render_success({ message: "Domain is not available" })
          end
        end

        private

        def reserve_new_domain(domain_name)
          reserved_domain_status = ReservedDomainStatus.new(name: domain_name)
          
          if reserved_domain_status.reserve_domain
            render_success({ 
              message: "Domain reserved successfully", 
              token: reserved_domain_status.access_token, 
              linkpay: reserved_domain_status.linkpay_url
            }, :created)
          else
            render_error("Failed to reserve domain", :unprocessable_entity, reserved_domain_status.errors.full_messages)
          end
        end

        def validate_params
          return if params[:domain_name].present?

          render_error("Missing required parameter: name", :bad_request)
        end
      end
    end
  end
end
