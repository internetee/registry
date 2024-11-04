module Api
  module V1
    module BusinessRegistry
      class LongReserveDomainsController < BaseController
        before_action :authenticate, only: [:create]
        skip_before_action :find_reserved_domain, only: [:create]
        before_action :domain_names
        before_action :validate_params
        before_action :available_domains?, only: [:create]

        def create
          result = ReserveDomainInvoice.create_list_of_domains(@domain_names, success_business_registry_customer_url, failed_business_registry_customer_url)

          if result.status_code_success
            render_success({ 
              message: "Domains are in pending status. Need to pay for domains.", 
              oneoff_payment_link: result.oneoff_payment_link,
              invoice_number: result.invoice_number,
              available_domains: ReserveDomainInvoice.filter_available_domains(@domain_names)
            }, :created)
          else
            render_error(result.details, :unprocessable_entity)
          end
        end

        private

        def success_business_registry_customer_url
          params[:success_business_registry_customer_url]
        end

        def failed_business_registry_customer_url
          params[:failed_business_registry_customer_url]
        end

        def domain_names
          @domain_names ||= params[:domain_names]
        end

        def available_domains?
          return if ReserveDomainInvoice.is_any_available_domains?(domain_names)

          render_error("No available domains", :unprocessable_entity)
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

          # Валидация URL параметров
          if params[:success_business_registry_customer_url].present?
            unless valid_url?(params[:success_business_registry_customer_url])
              render_error("Invalid success URL format", :bad_request)
              return
            end
          end

          if params[:failed_business_registry_customer_url].present?
            unless valid_url?(params[:failed_business_registry_customer_url])
              render_error("Invalid failed URL format", :bad_request)
              return
            end
          end
        end

        def valid_url?(url)
          uri = URI.parse(url)
          uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
        rescue URI::InvalidURIError
          false
        end
      end
    end
  end
end
