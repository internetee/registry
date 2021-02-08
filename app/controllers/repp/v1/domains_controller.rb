require 'serializers/repp/domain'
module Repp
  module V1
    class DomainsController < BaseController # rubocop:disable Metrics/ClassLength
      before_action :set_authorized_domain, only: %i[transfer_info destroy]
      before_action :validate_registrar_authorization, only: %i[transfer_info destroy]
      before_action :forward_registrar_id, only: %i[create update destroy]
      before_action :set_domain, only: %i[show update]

      api :GET, '/repp/v1/domains'
      desc 'Get all existing domains'
      def index
        records = current_user.registrar.domains
        domains = records.limit(limit).offset(offset)

        render_success(data: { domains: serialized_domains(domains),
                               total_number_of_records: records.count })
      end

      api :GET, '/repp/v1/domains/:domain_name'
      desc 'Get a specific domain'
      def show
        render_success(data: { domain: Serializers::Repp::Domain.new(@domain).to_json })
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
        param :admin_domain_contacts_attributes, Array, required: false,
                                                        desc: 'Admin domain contacts codes'
        param :tech_domain_contacts_attributes, Array, required: false,
                                                       desc: 'Tech domain contacts codes'
        param :dnskeys_attributes, Array, required: false, desc: 'DNSSEC keys for domain' do
          param_group :dns_keys_apidoc, Repp::V1::Domains::DnssecController
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
        action = ::Actions::DomainCreate.new(@domain, domain_create_params)

        # rubocop:disable Style/AndOr
        handle_errors(@domain) and return unless action.call
        # rubocop:enable Style/AndOr

        render_success(data: { domain: { name: @domain.name } })
      end

      api :PUT, '/repp/v1/domains/:domain_name'
      desc 'Update existing domain'
      param :id, String, desc: 'Domain name in IDN / Puny format'
      param :domain, Hash, required: true, desc: 'Changes of domain object' do
        param :registrant, Hash, required: false, desc: 'New registrant object' do
          param :code, String, required: true, desc: 'New registrant contact code'
          param :verified, [true, false], required: false,
                                          desc: 'Registrant change is already verified'
        end
        param :auth_info, String, required: false, desc: 'New authorization code'
      end
      def update
        action = ::Actions::DomainUpdate.new(@domain, params[:domain], false)

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

      api :DELETE, '/repp/v1/domains/:domain_name'
      desc 'Delete specific domain'
      param :delete, Hash, required: true, desc: 'Object holding verified key' do
        param :verified, [true, false], required: true,
                                        desc: 'Whether to ask registrant verification or not'
      end
      def destroy
        action = ::Actions::DomainDelete.new(@domain, params, current_user.registrar)

        # rubocop:disable Style/AndOr
        handle_errors(@domain) and return unless action.call
        # rubocop:enable Style/AndOr

        render_success(data: { domain: { name: @domain.name } })
      end

      private

      def serialized_domains(domains)
        return domains.pluck(:name) unless index_params[:details] == 'true'

        domains.map { |d| Serializers::Repp::Domain.new(d).to_json }
      end

      def initiate_transfer(transfer)
        domain = Epp::Domain.find_or_initialize_by(name: transfer[:domain_name])
        action = ::Actions::DomainTransfer.new(domain, transfer[:transfer_code],
                                             current_user.registrar)

        if action.call
          @successful << { type: 'domain_transfer', domain_name: domain.name }
        else
          @errors << { type: 'domain_transfer', domain_name: domain.name,
                       errors: domain.errors[:epp_errors] }
        end
      end

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
        registrar = current_user.registrar
        @domain = Epp::Domain.find_by(registrar: registrar, name: params[:id])
        @domain ||= Epp::Domain.find_by!(registrar: registrar, name_puny: params[:id])

        return @domain if @domain

        raise ActiveRecord::RecordNotFound
      end

      def set_authorized_domain
        @epp_errors ||= []
        @domain = domain_from_url_hash
      end

      def validate_registrar_authorization
        return if @domain.registrar == current_user.registrar
        return if @domain.transfer_code.eql?(request.headers['Auth-Code'])

        @epp_errors << { code: 2202, msg: I18n.t('errors.messages.epp_authorization_error') }
        handle_errors
      end

      def domain_from_url_hash
        entry = transfer_info_params[:id]
        return Epp::Domain.find(entry) if entry.match?(/\A[0-9]+\z/)

        Epp::Domain.find_by!('name = ? OR name_puny = ?', entry, entry)
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
        params.require(:domain).permit(:name, :registrant_id, :period, :period_unit, :registrar_id,
                                       dnskeys_attributes: [%i[flags alg protocol public_key]],
                                       nameservers_attributes: [[:hostname, ipv4: [], ipv6: []]],
                                       admin_domain_contacts_attributes: [],
                                       tech_domain_contacts_attributes: [])
      end
    end
  end
end
