require 'serializers/registrant_api/domain'

module Api
  module V1
    module Registrant
      class ConfirmsController < ::Api::V1::Registrant::BaseController
        skip_before_action :authenticate, :set_paper_trail_whodunnit
        before_action :set_domain, only: %i[index update]
        before_action :verify_action, only: %i[index update]
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

          unless delete_action? ? delete_action(verification) : change_action(verification)
            head :bad_request
            return
          end

          render json: { domain_name: @domain.name,
                         current_registrant: serialized_registrant(current_registrant),
                         status: params[:decision] }
        end

        private

        def initiator
          "email link, #{I18n.t(:user_not_authenticated)}"
        end

        def current_registrant
          approved? ? @domain.registrant : @domain.pending_registrant
        end

        def approved?
          params[:decision] == 'confirmed'
        end

        def change_action(verification)
          return verification.domain_registrant_change_confirm!(initiator) if approved?

          verification.domain_registrant_change_reject!(initiator)
        end

        def delete_action(verification)
          return verification.domain_registrant_delete_confirm!(initiator) if approved?

          verification.domain_registrant_delete_reject!(initiator)
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
            p.require(:template)
            p.require(:name)
            p.require(:token)
          end
        end

        def delete_action?
          return true if params[:template] == 'delete'

          false
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

        def verify_action
          action = if params[:template] == 'change'
                     @domain.registrant_update_confirmable?(verify_params[:token])
                   elsif params[:template] == 'delete'
                     @domain.registrant_delete_confirmable?(verify_params[:token])
                   end

          return unless action

          render json: { error: 'Application expired or not found' }, status: :unauthorized
        end
      end
    end
  end
end
