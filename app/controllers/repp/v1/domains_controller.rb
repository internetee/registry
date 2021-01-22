require 'serializers/registrant_api/domain'
module Repp
  module V1
    class DomainsController < BaseController
      before_action :set_authorized_domain, only: %i[transfer_info]
      before_action :forward_registrar_id, only: %i[create]
      before_action :set_domain, only: %i[show update]

      api :GET, '/repp/v1/domains'
      desc 'Get all existing domains'
      def index
        records = current_user.registrar.domains
        domains = records.limit(limit).offset(offset)
        domains = domains.pluck(:name) unless index_params[:details] == 'true'

        render_success(data: { domains: domains, total_number_of_records: records.count })
      end

      api :GET, '/repp/v1/domains/:domain_name'
      desc 'Get a specific domain'
      def show
        render_success(data: { domain: Serializers::RegistrantApi::Domain.new(@domain).to_json })
      end

      api :POST, '/repp/v1/domains'
      desc 'Create a new domain'
      param :domain, Hash, required: true, desc: 'Parameters for new domain' do
        param :name, String, required: true, desc: 'Domain name to be registered'
        param :registrant_id, String, required: true, desc: 'Registrant contact code'
        param :period, Integer, required: true, desc: 'Registration period in months or years'
        param :period_unit, String, required: true, desc: 'Period type (month m) or (year y)'
        param :nameservers_attributes, Array, required: false, desc: 'Domain nameservers' do
          param :hostname, String, required: true, desc: 'Nameserver hostname'
          param :ipv4, Array, desc: 'Array of IPv4 addresses'
          param :ipv6, Array, desc: 'Array of IPv4 addresses'
        end
        param :admin_domain_contacts_attributes, Array, required: false, desc: 'Admin domain contacts codes'
        param :tech_domain_contacts_attributes, Array, required: false, desc: 'Tech domain contacts codes'
        param :dnskeys_attributes, Array, required: false, desc: 'DNSSEC keys for domain' do
          param :flags, String, required: true, desc: 'Flag of DNSSEC key'
          param :protocol, String, required: true, desc: 'Protocol of DNSSEC key'
          param :alg, String, required: true, desc: 'Algorithm of DNSSEC key'
          param :public_key, String, required: true, desc: 'Public key of DNSSEC key'
        end
      end
      returns code: 200, desc: 'Successful domain registration response' do
        property :code, Integer, desc: 'EPP code'
        property :message, String, desc: 'EPP code explanation'
        property :data, Hash do
          property :domain, Hash do
            property :name, String, 'Domain name'
          end
        end
      end
      def create
        authorize!(:create, Epp::Domain)
        @domain = Epp::Domain.new
        action = Actions::DomainCreate.new(@domain, domain_create_params)

        handle_errors(@domain) and return unless action.call

        render_success(data: { domain: { name: @domain.name } })
      end

      api :PUT, '/repp/v1/domains/:domain_name'
      desc 'Update existing domain'
      param :id, String, desc: 'Domain name in IDN / Puny format'
      param :domain, Hash, required: true, desc: 'Changes of domain object' do
        param :registrant, Hash, required: false, desc: 'New registrant object' do
          param :code, String, required: true, desc: 'New registrant contact code'
          param :verified, [true, false], required: false, desc: 'Registrant change is already verified'
        end
        param :auth_info, String, required: false, desc: 'New authorization code'
      end
      def update
        action = Actions::DomainUpdate.new(@domain, params[:domain], current_user)

        unless action.call
          handle_errors(@domain)
          return
        end

        render_success(data: { domain: { name: @domain.name } })
      end

      api :GET, '/repp/v1/domains/:domain_name/transfer_info'
      desc "Retrieve specific domain's transfer info"
      def transfer_info
        contact_fields = %i[code name ident ident_type ident_country_code phone email street city
                            zip country_code statuses]

        data = {
          domain: @domain.name,
          registrant: @domain.registrant.as_json(only: contact_fields),
          admin_contacts: @domain.admin_contacts.map { |c| c.as_json(only: contact_fields) },
          tech_contacts: @domain.tech_contacts.map { |c| c.as_json(only: contact_fields) },
        }

        render_success(data: data)
      end

      api :POST, '/repp/v1/domains/transfer'
      desc 'Transfer multiple domains'
      def transfer
        @errors ||= []
        @successful = []

        transfer_params[:domain_transfers].each do |transfer|
          initiate_transfer(transfer)
        end

        render_success(data: { success: @successful, failed: @errors })
      end

      def initiate_transfer(transfer)
        domain = Epp::Domain.find_or_initialize_by(name: transfer[:domain_name])
        action = Actions::DomainTransfer.new(domain, transfer[:transfer_code],
                                             current_user.registrar)

        if action.call
          @successful << { type: 'domain_transfer', domain_name: domain.name }
        else
          @errors << { type: 'domain_transfer', domain_name: domain.name,
                       errors: domain.errors[:epp_errors] }
        end
      end

      private

      def transfer_params
        params.require(:data).require(:domain_transfers).each do |t|
          t.require(:domain_name)
          t.permit(:domain_name)
          t.require(:transfer_code)
          t.permit(:transfer_code)
        end
        params.require(:data).permit(domain_transfers: %i[domain_name transfer_code])
      end

      def transfer_info_params
        params.require(:id)
        params.permit(:id)
      end

      def forward_registrar_id
        return unless params[:domain]

        params[:domain][:registrar_id] = current_user.registrar.id
      end

      def set_domain
        @domain = Epp::Domain.find_by!(registrar: current_user.registrar, name: params[:id])
      end

      def set_authorized_domain
        @epp_errors ||= []
        h = {}
        h[transfer_info_params[:id].match?(/\A[0-9]+\z/) ? :id : :name] = transfer_info_params[:id]
        @domain = Domain.find_by!(h)

        validate_registrar_authorization
      end

      def validate_registrar_authorization
        return if @domain.registrar == current_user.registrar
        return if @domain.transfer_code.eql?(request.headers['Auth-Code'])

        @epp_errors << { code: 2202, msg: I18n.t('errors.messages.epp_authorization_error') }
        handle_errors
      end

      def limit
        index_params[:limit] || 200
      end

      def offset
        index_params[:offset] || 0
      end

      def index_params
        params.permit(:limit, :offset, :details)
      end

      def domain_create_params
        params.require(:domain).require([:name, :registrant_id, :period, :period_unit])
        params.require(:domain).permit(:name, :registrant_id, :period, :period_unit, :registrar_id)
      end
    end
  end
end
