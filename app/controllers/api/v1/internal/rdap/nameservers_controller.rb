module Api
  module V1
    module Internal
      module Rdap
        class NameserversController < BaseController
          # Thin shape: {hostname, hostname_puny} only, DISTINCT-collapsed.
          # A host serves many domains (no global unique on hostname) — return
          # one result. NO glue (ipv4/ipv6), NO domain list (prevents
          # enumeration disclosure).
          def show
            host = params[:host].to_s
            nameserver = Nameserver
                         .where(hostname: host).or(Nameserver.where(hostname_puny: host))
                         .first

            if nameserver
              render json: {
                hostname: nameserver.hostname,
                hostname_puny: nameserver.hostname_puny,
              }, status: :ok
            else
              render_error('Nameserver not found', :not_found)
            end
          end
        end
      end
    end
  end
end
