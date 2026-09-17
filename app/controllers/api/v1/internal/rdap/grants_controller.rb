module Api
  module V1
    module Internal
      module Rdap
        class GrantsController < BaseController
          # GET /api/v1/internal/rdap/grants/active?subject=:eeid_subject
          #
          # Resolve the single active privileged-access grant for an eeID
          # subject. "Active" is computed server-side (RdapPrivilegeGrant
          # .active_for_subject); on multiple active grants the latest valid_from
          # wins. Fail-closed: no active grant -> 404 (RDAP never escalates to
          # privileged). The subject is sensitive PII (a national id): read it
          # from the query string, never from the path, and do not log it.
          def active
            grant = RdapPrivilegeGrant.active_for_subject(params[:subject]).first

            if grant
              render json: serialize(grant), status: :ok
            else
              render_error('No active grant', :not_found)
            end
          end

          # POST /api/v1/internal/rdap/grants/:id/touch
          #
          # Best-effort last-used marker. Non-blocking, idempotent. 204 on
          # success, 404 if the grant is unknown.
          def touch
            grant = RdapPrivilegeGrant.find_by(uuid: params[:id]) ||
                    RdapPrivilegeGrant.find_by(id: params[:id])

            return render_error('Grant not found', :not_found) unless grant

            grant.update_columns(last_used_at: Time.zone.now)
            head :no_content
          end

          private

          def serialize(grant)
            {
              grant_id: grant.grant_id,
              eeid_subject: grant.eeid_subject,
              privilege_category: grant.category,
              organization: grant.organization.presence || grant.category,
              privileges: [grant.category],
              status: grant.status,
              valid_from: iso8601(grant.valid_from),
              valid_until: iso8601(grant.valid_until),
            }
          end

          def iso8601(value)
            value&.utc&.iso8601
          end
        end
      end
    end
  end
end
