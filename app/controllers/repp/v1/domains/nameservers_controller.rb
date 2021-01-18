module Repp
  module V1
    module Domains
      class NameserversController < BaseController
        before_action :set_domain, only: %i[create destroy]
        before_action :set_nameserver, only: %i[destroy]

        api :POST, '/repp/v1/domains/:domain_name/nameservers'
        desc 'Creates new nameserver for domain'
        param :nameservers, Array, required: true, desc: 'Array of new nameservers' do
          param :hostname, String, required: true, desc: 'Nameserver hostname'
          param :ipv4, Array, required: false, desc: 'Array of IPv4 values'
          param :ipv6, Array, required: false, desc: 'Array of IPv6 values'
        end
        def create
          nameserver_params[:nameservers].each { |n|  n[:action] = 'add' }
          action = Actions::DomainUpdate.new(@domain, params, current_user)

          unless action.call
            handle_errors(@domain)
            return
          end

          render_success(data: { domain: { name: @domain.name } })
        end

        api :POST, '/repp/v1/domains/:domain/nameservers/:nameserver'
        desc 'Modifiy nameserver for domain'
        param :nameserver, Hash, required: true, desc: 'Nameserver parameters' do
          param :hostname, String, required: true, desc: 'Nameserver hostname'
          param :ipv4, Array, required: false, desc: 'Array of IPv4 values'
          param :ipv6, Array, required: false, desc: 'Array of IPv6 values'
        end

        api :DELETE, '/repp/v1/domains/:domain/nameservers/:nameserver'
        desc 'Delete nameserver for domain'
        def destroy
          nameserver = { nameservers: [{ hostname: params[:id], action: 'rem' }] }
          action = Actions::DomainUpdate.new(@domain, nameserver, current_user)

          unless action.call
            handle_errors(@domain)
            return
          end

          render_success(data: { domain: { name: @domain.name } })
        end

        private

        def set_domain
          registrar = current_user.registrar
          @domain = Epp::Domain.find_by(registrar: registrar, name: params[:domain_id])
          @domain ||= Epp::Domain.find_by!(registrar: registrar, name_puny: params[:domain_id])

          @domain
        end

        def set_nameserver
          @nameserver = @domain.nameservers.find_by!(hostname: params[:id])
        end

        def nameserver_params
          params.permit!
        end
      end
    end
  end
end
