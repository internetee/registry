module Repp
  module V1
    module Registrar
      class NameserversController < BaseController
        before_action :verify_nameserver_existance, only: %i[update]

        api :PUT, 'repp/v1/registrar/nameservers'
        desc 'bulk nameserver change'
        param :data, Hash, required: true, desc: 'Object holding nameserver changes' do
          param :type, String, required: true, desc: 'Always set as "nameserver"'
          param :id, String, required: true, desc: 'Hostname of replacable nameserver'
          param :domains, Array, required: true, desc: 'Array of domain names qualified for ' \
                                                       'nameserver replacement'
          param :attributes, Hash, required: true, desc: 'Object holding new nameserver values' do
            param :hostname, String, required: true, desc: 'New hostname of nameserver'
            param :ipv4, Array, required: false, desc: 'Array of fixed IPv4 addresses'
            param :ipv6, Array, required: false, desc: 'Array of fixed IPv6 addresses'
          end
        end
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
