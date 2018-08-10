require 'rails5_api_controller_backport'

module Api
  module V1
    module Registrant
      class DomainsController < BaseController
        def index
          limit = params[:limit] || 200
          offset = params[:offset] || 0

          if limit.to_i > 200 || limit.to_i < 1
            render(json: { errors: [{ limit: ['parameter is out of range'] }] },
                   status: :bad_request) && return
          end

          if offset.to_i.negative?
            render(json: { errors: [{ offset: ['parameter is out of range'] }] },
                   status: :bad_request) && return
          end

          @domains = associated_domains(current_registrant_user).limit(limit).offset(offset)
          render json: @domains
        end

        def show
          domain_pool = associated_domains(current_registrant_user)
          @domain = domain_pool.find_by(uuid: params[:uuid])

          if @domain
            render json: @domain
          else
            render json: { errors: [{ base: ['Domain not found'] }] }, status: :not_found
          end
        end

        private

        def associated_domains(user)
          country_code, ident = user.registrant_ident.split('-')

          BusinessRegistryCache.fetch_associated_domains(ident, country_code)
        rescue Soap::Arireg::NotAvailableError => error
          Rails.logger.fatal("[EXCEPTION] #{error}")
          user.domains
        end
      end
    end
  end
end
