module Repp
  module V1
    module Registrar
      class NameserversController < BaseController
        before_action :verify_nameserver_existance, only: %i[update]

        def update
          affected, errored = current_user.registrar
                                          .replace_nameservers(hostname,
                                                               hostname_params[:data][:attributes],
                                                               domains: domains_from_params)

          render_success(data: data_format_for_success(affected, errored))
        rescue ActiveRecord::RecordInvalid => e
          handle_errors(e.record)
        end

        private

        def domains_from_params
          return [] unless params[:data][:domains]

          params[:data][:domains].map(&:downcase)
        end

        def data_format_for_success(affected_domains, errored_domains)
          {
            type: 'nameserver',
            id: params[:data][:attributes][:hostname],
            attributes: params[:data][:attributes],
            affected_domains: affected_domains,
            skipped_domains: errored_domains,
          }
        end

        def hostname_params
          params.require(:data).require(%i[type id])
          params.require(:data).require(:attributes).require([:hostname])

          params.permit(data: [
                          :type, :id,
                          { domains: [],
                            attributes: [:hostname, { ipv4: [], ipv6: [] }] }
                        ])
        end

        def hostname
          hostname_params[:data][:id]
        end

        def verify_nameserver_existance
          current_user.registrar.nameservers.find_by!(hostname: hostname)
        end
      end
    end
  end
end
