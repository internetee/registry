module Api
  module V1
    module BusinessRegistry
      class LongReserveDomainsController < BaseController
        before_action :domain_names
        before_action :validate_params
        before_action :available_domains?, only: [:create]

        def create
          # TODO: need to refactor this
          available_domains_count = ::BusinessRegistry::DomainAvailabilityCheckerService.filter_available(@domain_names).count
          unless available_domains_count == @domain_names.count
            render_error("Some domains are not available", :unprocessable_entity)
            return
          end

          result = ReserveDomainInvoice.create_list_of_domains(@domain_names)

          if result.status_code_success
            render_success({ 
              message: "Domains are in pending status. Need to pay for domains.", 
              linkpay_url: decode_linkpay_url(result.linkpay_url),
              invoice_number: result.invoice_number,
              user_unique_id: result.user_unique_id,
              available_domains: ReserveDomainInvoice.filter_available_domains(@domain_names)
            }, :created)
          else
            render_error(result.details, :unprocessable_entity)
          end
        end

        private

        def decode_linkpay_url(url)
          return url if url.blank?
          CGI.unescape(url.gsub('\u0026', '&'))
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
        end
      end
    end
  end
end
