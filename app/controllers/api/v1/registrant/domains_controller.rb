require 'rails5_api_controller_backport'

module Api
  module V1
    module Registrant
      class DomainsController < BaseController
        def index
          @domains = associated_domains(current_user)
          render json: @domains
        end

        def show
          domain_pool = associated_domains(current_user)
          @domain = domain_pool.find_by(uuid: params[:uuid])

          if @domain
            render json: @domain
          else
            render json: { errors: ["Domain not found"] }, status: :not_found
          end
        end

        private

        def associated_domains(user)
          country_code, ident = user.registrant_ident.split('-')

          BusinessRegistryCache.fetch_associated_domains(ident, country_code)
        rescue Soap::Arireg::NotAvailableError => error
          Rails.logger.fatal("[EXCEPTION] #{error.to_s}")
          user.domains
        end
      end
    end
  end
end
