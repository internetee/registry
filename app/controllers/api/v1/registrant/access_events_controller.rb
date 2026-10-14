module Api
  module V1
    module Registrant
      # Read-only (spec 13, Surface A). Lists the authority accesses the authenticated
      # registrant is entitled to see for ONE of their own domains, addressed by uuid.
      # Auth is inherited UNCHANGED from BaseController (Bearer -> current_registrant_user).
      class AccessEventsController < ::Api::V1::Registrant::BaseController
        # GET /api/v1/registrant/domains/:uuid/access_events
        def index
          # R8/AC9: does the caller CURRENTLY own THIS uuid? Same single branch for an
          # unknown uuid and another registrant's uuid, so the two 404 bodies are
          # byte-identical and reveal nothing about existence under another registrant.
          domain = current_registrant_user.domains.find_by(uuid: params[:domain_uuid])
          return render json: { errors: [{ base: ['Domain not found'] }] },
                        status: :not_found unless domain

          # Scoping derived EXCLUSIVELY from current_registrant_user (R4/N3): the action
          # never reads params[:registrant_id] / params[:contact_id] / an ident header.
          events = RegistrantAccessEventsQuery.new(domain: domain,
                                                   registrant_user: current_registrant_user).call

          # EXACTLY the three R9 keys (N1/AC13): withheld fields cannot appear structurally.
          render json: events.map { |event|
            {
              accessed_at: event.requested_at.iso8601,
              organization: event.organization_name,
              category: event.category,
            }
          }
        end
      end
    end
  end
end
