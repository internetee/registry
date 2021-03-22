module Repp
  module V1
    module Domains
      class NameserversController < BaseController
        before_action :set_domain, only: %i[index create destroy]
        before_action :set_nameserver, only: %i[destroy]

        api :GET, '/repp/v1/domains/:domain_name/nameservers'
        desc "Get domain's nameservers"
        def index
          nameservers = @domain.nameservers
          data = { nameservers: nameservers.as_json(only: %i[hostname ipv4 ipv6]) }
          render_success(data: data)
        end

        api :POST, '/repp/v1/domains/:domain_name/nameservers'
        desc 'Create new nameserver for domain'
        param :nameservers, Array, required: true, desc: 'Array of new nameservers' do
          param :hostname, String, required: true, desc: 'Nameserver hostname'
          param :ipv4, Array, required: false, desc: 'Array of IPv4 values'
          param :ipv6, Array, required: false, desc: 'Array of IPv6 values'
        end
        def create
          params[:nameservers].each { |n| n[:action] = 'add' }
          action = Actions::DomainUpdate.new(@domain, nameserver_params, current_user)

          unless action.call
            handle_errors(@domain)
            return
          end

          render_success(data: { domain: { name: @domain.name } })
        end

        api :DELETE, '/repp/v1/domains/:domain/nameservers/:nameserver'
        desc 'Delete specific nameserver from domain'
        def destroy
          nameserver = { nameservers: [{ hostname: params[:id], action: 'rem' }] }
          action = Actions::DomainUpdate.new(@domain, nameserver, false)

          unless action.call
            handle_errors(@domain)
            return
          end

          render_success(data: { domain: { name: @domain.name } })
        end

        private

        def set_nameserver
          @nameserver = @domain.nameservers.find_by!(hostname: params[:id])
        end

        def nameserver_params
          params.permit(:domain_id, nameservers: [[:hostname, :action, ipv4: [], ipv6: []]])
        end
      end
    end
  end
end
