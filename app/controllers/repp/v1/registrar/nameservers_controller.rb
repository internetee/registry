module Repp
  module V1
    module Registrar
      class NameserversController < BaseController
        before_action :verify_nameserver_existance, only: %i[update]

        api :PUT, 'repp/v1/registrar/nameservers'
        desc 'bulk nameserver change'
        param :data, Hash, required: true, desc: 'Object holding nameserver changes' do
          param :type, String, required: true, desc: 'Always set as "nameserver"'
          param :id, String, required: false, desc: 'Hostname of replacable nameserver'
          param :domains, Array, required: false, desc: 'Array of domain names qualified for ' \
                                                       'nameserver replacement'
          param :attributes, Hash, required: true, desc: 'Object holding new nameserver values' do
            param :hostname, String, required: true, desc: 'New hostname of nameserver'
            param :ipv4, Array, of: String, required: false, desc: 'Array of fixed IPv4 addresses'
            param :ipv6, Array, of: String, required: false, desc: 'Array of fixed IPv6 addresses'
          end
        end

        def update  # rubocop:disable Metrics/MethodLength
          authorize! :manage, :repp
          affected, errored = if hostname.present?
                                current_user.registrar
                                            .replace_nameservers(hostname,
                                                                 hostname_params[:attributes],
                                                                 domains: domains_from_params)
                              else
                                current_user.registrar
                                            .add_nameservers(hostname_params[:attributes],
                                                             domains: domains_from_params)
                              end

          render_success(data: data_format_for_success(affected, errored))
        rescue ActiveRecord::RecordInvalid => e
          handle_errors(e.record)
        end

        private

        def domains_from_params
          return [] unless hostname_params[:domains]

          hostname_params[:domains].map(&:downcase)
        end

        def data_format_for_success(affected_domains, errored_domains)
          {
            type: 'nameserver',
            id: hostname_params[:attributes][:hostname],
            attributes: hostname_params[:attributes],
            affected_domains: affected_domains,
            skipped_domains: errored_domains,
          }
        end

        def hostname_params
          params.require(:data).permit(:type, :id, nameserver: [], domains: [],
                                                   attributes: [:hostname, { ipv4: [], ipv6: [] }])
                .tap do |data|
                  data.require(:type)
                  data.require(:attributes).require([:hostname])
                end
        end

        def hostname
          hostname_params[:id] || nil
        end

        def verify_nameserver_existance
          return true if hostname.blank?

          current_user.registrar.nameservers.find_by!(hostname: hostname)
        end
      end
    end
  end
end
