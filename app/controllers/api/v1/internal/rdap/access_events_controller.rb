module Api
  module V1
    module Internal
      module Rdap
        # Registry-side store for PRIVILEGED RDAP access events (RDAP spec 11).
        # RDAP owns no database; on a real (result_code 200) privileged disclosure
        # it POSTs the non-PII facts here and the registry snapshots the resolved
        # grant into an insert-only row. The eeID subject / personal id code are
        # sensitive PII and MUST NEVER be read or stored here.
        class AccessEventsController < BaseController
          # POST /api/v1/internal/rdap/access-events
          # Body: grant_id, domain_name, requested_at, caller_ip, result_code,
          # request_id (optional). Returns 204 on success.
          def create
            grant = RdapPrivilegeGrant.find_by(uuid: params[:grant_id]) ||
                    RdapPrivilegeGrant.find_by(id: params[:grant_id])
            return render_error('Grant not found', :not_found) unless grant
            return render_error('result_code must be 200', :unprocessable_entity) if params[:result_code].to_i != 200

            requested_at = parse_time(params[:requested_at])
            return render_error('requested_at is invalid', :unprocessable_entity) if requested_at.nil?

            event = RdapAccessEvent.new(
              requested_at:      requested_at,
              domain_name:       params[:domain_name],
              caller_ip:         params[:caller_ip],
              result_code:       params[:result_code],
              organization_name: grant.organization,
              accessor_name:     grant.full_name,
              category:          grant.category,
              grant_ref:         grant.grant_id,
              request_id:        params[:request_id].presence
            )

            if event.save
              head :no_content
            else
              render_error(event.errors.full_messages.join(', '), :unprocessable_entity)
            end
          rescue StandardError => e
            # Unexpected persistence error ONLY. The explicit rescue is required so
            # the technical-log error + failure metric run before returning 500 —
            # BaseController's rescue_from would render 500 but skip the telemetry.
            # NEVER log eeid_subject / personal_id_code.
            Rails.logger.error("[rdap_access_event] record failed domain=#{params[:domain_name]} " \
                               "grant_ref=#{grant&.grant_id} error=#{e.class}: #{e.message}")
            NewRelic::Agent.increment_metric('Custom/Rdap/access_event_record_failure')
            render_error('Access event could not be recorded', :internal_server_error)
          end

          private

          def parse_time(value)
            return nil if value.blank?

            Time.zone.parse(value.to_s)
          rescue ArgumentError
            nil
          end
        end
      end
    end
  end
end
