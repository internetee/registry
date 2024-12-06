module Api
  module V1
    module BusinessRegistry
      class ReserveDomainsController < BaseController
        before_action :validate_params, only: :create
        before_action :set_free_domain_reservation_holder, only: :show

        def show
          render_success(@free_domain_reservation_holder.output_reserved_domains)
        end

        def create
          domain_names = params[:domain_names]
          result = ReservedDomain.reserve_domains_without_payment(domain_names)

          if result.success
            render_success({ 
              message: "Domains reserved successfully", 
              reserved_domains: result.reserved_domains.map do |domain|
                {
                  name: domain.name,
                  password: domain.password,
                  expire_at: domain.expire_at
                }
              end,
              user_unique_id: result.user_unique_id
            }, :created)
          else
            render_error(result.errors, :unprocessable_entity)
          end
        end

        private

        def set_free_domain_reservation_holder
          @free_domain_reservation_holder = FreeDomainReservationHolder.find_by(user_unique_id: params[:user_unique_id])
          render_error("Reserved domains not found. Invalid user_unique_id", :not_found) unless @free_domain_reservation_holder
        end

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
