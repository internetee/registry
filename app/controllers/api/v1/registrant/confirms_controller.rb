require 'serializers/registrant_api/domain'

module Api
  module V1
    module Registrant
      class ConfirmsController < ::Api::V1::Registrant::BaseController
        skip_before_action :authenticate, :set_paper_trail_whodunnit
        before_action :set_domain, only: %i[index update]
        before_action :verify_updateable, only: %i[index update]

        def index
          render json: {
            domain_name: @domain.name,
            current_registrant: serialized_registrant(@domain.registrant),
            new_registrant: serialized_registrant(@domain.pending_registrant)
          }
        end

        def update
        end

        private

        def serialized_registrant(registrant)
          {
            name: registrant.try(:name),
            ident: registrant.try(:ident),
            country: registrant.try(:ident_country_code)
          }
        end

        def confirmation_params
          params do |p|
            p.require(:name)
            p.require(:token)
          end
        end

        def set_domain
          @domain = Domain.find_by(name: confirmation_params[:name])
          return if @domain

          render json: { error: 'Domain not found' }, status: :not_found
        end

        def verify_updateable
          return if @domain.registrant_update_confirmable?(confirmation_params[:token])

          render json: { error: 'Application expired or not found' },
          status: :unauthorized
        end
      end
    end
  end
end
