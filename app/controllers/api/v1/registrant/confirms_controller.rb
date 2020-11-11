require 'serializers/registrant_api/domain'

module Api
  module V1
    module Registrant
      class ConfirmsController < ::Api::V1::Registrant::BaseController
        skip_before_action :authenticate, :set_paper_trail_whodunnit
        before_action :set_domain, only: %i[index update]
        before_action :verify_updateable, only: %i[index update]
        before_action :verify_decision, only: %i[update]

        def index
          render json: {
            domain_name: @domain.name,
            current_registrant: serialized_registrant(@domain.registrant),
            new_registrant: serialized_registrant(@domain.pending_registrant),
          }
        end

        def update
          verification = RegistrantVerification.new(domain_id: @domain.id,
                                                    verification_token: verify_params[:token])

          head(:bad_request) and return unless update_action(verification)

          render json: {
            domain_name: @domain.name,
            current_registrant: serialized_registrant(current_registrant),
            status: params[:decision],
          }
        end

        private

        def current_registrant
          changes_registrant? ? @domain.registrant : @domain.pending_registrant
        end

        def changes_registrant?
          params[:decision] == 'confirmed'
        end

        def update_action(verification)
          initiator = "email link, #{I18n.t(:user_not_authenticated)}"
          if changes_registrant?
            verification.domain_registrant_change_confirm!(initiator)
          else
            verification.domain_registrant_change_reject!(initiator)
          end
        end

        def serialized_registrant(registrant)
          {
            name: registrant.try(:name),
            ident: registrant.try(:ident),
            country: registrant.try(:ident_country_code),
          }
        end

        def verify_params
          params do |p|
            p.require(:name)
            p.require(:token)
          end
        end

        def verify_decision
          return if %w[confirmed rejected].include?(params[:decision])

          head :bad_request
        end

        def set_domain
          @domain = Domain.find_by(name: verify_params[:name])
          @domain ||= Domain.find_by(name_puny: verify_params[:name])
          return if @domain

          render json: { error: 'Domain not found' }, status: :not_found
        end

        def verify_updateable
          return if @domain.registrant_update_confirmable?(verify_params[:token])

          render json: { error: 'Application expired or not found' }, status: :unauthorized
        end
      end
    end
  end
end
