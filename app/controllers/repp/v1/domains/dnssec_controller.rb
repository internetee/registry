module Repp
  module V1
    module Domains
      class DnssecController < BaseController
        before_action :set_domain, only: %i[index create destroy]

        THROTTLED_ACTIONS = %i[index create destroy].freeze
        include Shunter::Integration::Throttle

        def_param_group :dns_keys_apidoc do
          param :flags, String, required: true, desc: '256 (KSK) or 257 (ZSK)'
          param :protocol, String, required: true, desc: 'Key protocol (3)'
          param :alg, String, required: true, desc: 'DNSSEC key algorithm (3,5,6,7,8,10,13,14)'
          param :public_key, String, required: true, desc: 'DNSSEC public key'
        end

        api :GET, '/repp/v1/domains/:domain_name/dnssec'
        desc "View specific domain's DNSSEC keys"
        def index
          dnssec_keys = @domain.dnskeys
          data = { dns_keys: dnssec_keys.as_json(only: %i[flags alg protocol public_key]) }
          render_success(data: data)
        end

        api :POST, '/repp/v1/domains/:domain_name/dnssec'
        desc 'Create a new DNSSEC key(s) for domain'
        param :dns_keys, Array, required: true, desc: 'Array of new DNSSEC keys' do
          param_group :dns_keys_apidoc, DnssecController
        end
        def create
          cta('add')
        end

        api :DELETE, 'repp/v1/domains/:domain_name/dnssec'
        param :dns_keys, Array, required: true, desc: 'Array of new DNSSEC keys' do
          param_group :dns_keys_apidoc, DnssecController
        end
        def destroy
          cta('rem')
        end

        def cta(action = 'add')
          params[:dns_keys].each { |n| n[:action] = action }
          action = Actions::DomainUpdate.new(@domain, dnssec_params, false)

          # rubocop:disable Style/AndOr
          (handle_errors(@domain) and return) unless action.call
          # rubocop:enable Style/AndOr

          render_success(data: { domain: { name: @domain.name } })
        end

        private

        def dnssec_params
          params.permit(:domain_id, dns_keys: [%i[action flags protocol alg public_key]])
        end
      end
    end
  end
end
