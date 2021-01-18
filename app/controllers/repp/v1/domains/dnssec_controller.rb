module Repp
  module V1
    module Domains
      class DnssecController < BaseController
        before_action :set_domain, only: %i[index create destroy]

        api :GET, '/repp/v1/domains/:domain_name/dnssec'
        desc "View all domain's DNSSEC keys"
        def index
          dnssec_keys = @domain.dnskeys
          data = { dns_keys: dnssec_keys.as_json(only: %i[flags alg protocol public_key]) }
          render_success(data: data)
        end

        api :POST, '/repp/v1/domains/:domain_name/dnssec'
        desc 'Add new DNSSEC key(s) to domain'
        param :dns_keys, Array, required: true, desc: 'Array of new DNSSEC keys' do
          param :flags, String, required: true, desc: '256 (KSK) or 257 (ZSK)'
          param :protocol, String, required: true, desc: 'Key protocol (3)'
          param :alg, String, required: true, desc: 'DNSSEC key algorithm (3,5,6,7,8,10,13,14)'
          param :public_key, String, required: true, desc: 'DNSSEC public key'
        end
        def create
          dnssec_params[:dnssec][:dns_keys].each { |n| n[:action] = 'add' }
          action = Actions::DomainUpdate.new(@domain, dnssec_params[:dnssec], current_user)

          unless action.call
            handle_errors(@domain)
            return
          end

          render_success(data: { domain: { name: @domain.name } })
        end

        api :DELETE, 'repp/v1/domains/:domain_name/dnssec'
        param :dns_keys, Array, required: true, desc: 'Array of removable DNSSEC keys' do
          param :flags, String, required: true, desc: '256 (KSK) or 257 (ZSK)'
          param :protocol, String, required: true, desc: 'Key protocol (3)'
          param :alg, String, required: true, desc: 'DNSSEC key algorithm (3,5,6,7,8,10,13,14)'
          param :public_key, String, required: true, desc: 'DNSSEC public key'
        end
        def destroy
          dnssec_params[:dnssec][:dns_keys].each { |n| n[:action] = 'rem' }
          action = Actions::DomainUpdate.new(@domain, dnssec_params[:dnssec], current_user)

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

        def dnssec_params
          params.permit!
        end
      end
    end
  end
end
