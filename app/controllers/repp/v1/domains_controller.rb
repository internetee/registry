require 'serializers/repp/domain'
module Repp
  module V1
    class DomainsController < BaseController # rubocop:disable Metrics/ClassLength
      before_action :set_authorized_domain, only: %i[transfer_info destroy]
      before_action :find_password, only: %i[update destroy]
      before_action :validate_registrar_authorization, only: %i[transfer_info destroy]
      before_action :forward_registrar_id, only: %i[create update destroy]
      before_action :set_domain, only: %i[update]

      api :GET, '/repp/v1/domains'
      desc 'Get all existing domains'
      def index
        authorize! :info, Epp::Domain
        records = current_user.registrar.domains
        q = records.ransack(search_params)
        q.sorts = ['valid_to asc', 'created_at desc'] if q.sorts.empty?
        # use distinct: false here due to ransack bug:
        # https://github.com/activerecord-hackery/ransack/issues/429
        domains = q.result(distinct: false)

        limited_domains = domains.limit(limit).offset(offset).includes(:registrar, :registrant)

        render_success(data: { new_domain: records.any? ? serialized_domains([records.last]) : [],
                               domains: serialized_domains(limited_domains.to_a.uniq),
                               count: domains.count,
                               statuses: DomainStatus::STATUSES })
      end

      api :GET, '/repp/v1/domains/:domain_name'
      desc 'Get a specific domain'
      def show
        @domain = Epp::Domain.find_by(name: params[:id])
        authorize! :info, @domain

        sponsor = @domain.registrar == current_user.registrar
        serializer = Serializers::Repp::Domain.new(@domain, sponsored: sponsor)
        render_success(data: { domain: serializer.to_json })
      end

      api :POST, '/repp/v1/domains'
      desc 'Create a new domain'
      param :domain, Hash, required: true, desc: 'Parameters for new domain' do
        param :name, String, required: true, desc: 'Domain name to be registered'
        param :registrant, String, required: true, desc: 'Registrant contact code'
        param :reserved_pw, String, required: false, desc: 'Reserved password for domain'
        param :transfer_code, String, required: false, desc: 'Desired transfer code for domain'
        param :period, Integer, required: true, desc: 'Registration period in months or years'
        param :period_unit, String, required: true, desc: 'Period type (month m) or (year y)'
        param :nameservers_attributes, Array, required: false, desc: 'Domain nameservers' do
          param :hostname, String, required: true, desc: 'Nameserver hostname'
          param :ipv4, Array, desc: 'Array of IPv4 addresses'
          param :ipv6, Array, desc: 'Array of IPv4 addresses'
        end
        param :admin_contacts, Array, required: false, desc: 'Admin domain contacts codes'
        param :tech_contacts, Array, required: false, desc: 'Tech domain contacts codes'
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
        authorize! :create, Epp::Domain
        @domain = Epp::Domain.new

        action = Actions::DomainCreate.new(@domain, domain_params)

        # rubocop:disable Style/AndOr
        handle_errors(@domain) and return unless action.call
        # rubocop:enable Style/AndOr

        render_success(data: { domain: { name: @domain.name,
                                         transfer_code: @domain.transfer_code,
                                         id: @domain.reload.uuid } })
      end

      api :PUT, '/repp/v1/domains/:domain_name'
      desc 'Update existing domain'
      param :id, String, desc: 'Domain name in IDN / Puny format'
      param :domain, Hash, required: true, desc: 'Changes of domain object' do
        param :registrant, Hash, required: false, desc: 'New registrant object' do
          param :code, String, required: true, desc: 'New registrant contact code'
          param :verified, [true, false, 'true', 'false'], required: false,
                                                           desc: 'Registrant change is already verified'
        end
        param :transfer_code, String, required: false, desc: 'New authorization code'
      end
      def update
        authorize!(:update, @domain, @password)
        action = Actions::DomainUpdate.new(@domain, update_params, false)
        unless action.call
          handle_errors(@domain)
          return
        end

        render_success(data: { domain: { name: @domain.name, id: @domain.uuid } })
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
        authorize! :transfer, Epp::Domain
        @errors ||= []
        @successful = []
        transfer_params[:domain_transfers].each do |transfer|
          initiate_transfer(transfer)
        end

        render_success(data: { success: @successful, failed: @errors })
      end

      api :DELETE, '/repp/v1/domains/:domain_name'
      desc 'Delete specific domain'
      param :id, String, desc: 'Domain name in IDN / Puny format'
      param :domain, Hash, required: true, desc: 'Changes of domain object' do
        param :delete, Hash, required: true, desc: 'Object holding verified key' do
          param :verified, [true, false, 'true', 'false'], required: true,
                                                           desc: 'Whether to ask registrant verification or not'
        end
      end
      def destroy
        authorize!(:delete, @domain, @password)
        action = Actions::DomainDelete.new(@domain, domain_params, current_user.registrar)

        # rubocop:disable Style/AndOr
        handle_errors(@domain) and return unless action.call
        # rubocop:enable Style/AndOr

        render_success(data: { domain: { name: @domain.name } })
      end

      private

      def serialized_domains(domains)
        return domains.pluck(:name) unless index_params[:details] == 'true'

        simple = index_params[:simple] == 'true' || false
        domains.map { |d| Serializers::Repp::Domain.new(d, simplify: simple).to_json }
      end

      def initiate_transfer(transfer)
        domain = Epp::Domain.find_or_initialize_by(name: transfer[:domain_name])
        action = Actions::DomainTransfer.new(domain, transfer[:transfer_code],
                                             current_user.registrar)

        if action.call
          @successful << { type: 'domain_transfer', domain_name: domain.name }
        else
          @errors << { type: 'domain_transfer', domain_name: domain.name,
                       errors: domain.errors.where(:epp_errors).first.options }
        end
      end

      def transfer_params
        params.require(:data).require(:domain_transfers)
        params.require(:data).permit(domain_transfers: [%i[domain_name transfer_code]])
      end

      def transfer_info_params
        params.require(:id)
        params.permit(:id, :legal_document, delete: [:verified])
      end

      def forward_registrar_id
        return unless params[:domain]

        params[:domain][:registrar] = current_user.registrar.id
      end

      def set_domain
        registrar = current_user.registrar

        @domain = Epp::Domain.find_by(registrar: registrar, name: params[:id])
        @domain ||= Epp::Domain.find_by!(registrar: registrar, name_puny: params[:id])

        return @domain if @domain

        raise ActiveRecord::RecordNotFound
      end

      def find_password
        @password = domain_params[:transfer_code]
      end

      def set_authorized_domain
        @epp_errors ||= ActiveModel::Errors.new(self)
        @domain = domain_from_url_hash
      end

      def validate_registrar_authorization
        return if @domain.registrar == current_user.registrar
        return if @domain.transfer_code.eql?(request.headers['Auth-Code'])

        @epp_errors.add(:epp_errors,
                        code: 2202,
                        msg: I18n.t('errors.messages.epp_authorization_error'))
        handle_errors
      end

      def domain_from_url_hash
        entry = params[:id]
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
        params.permit(:limit, :offset, :details, :simple, :q,
                      q: %i[s name_matches registrant_id_eq contacts_ident_eq
                            nameservers_hostname_eq valid_to_gteq valid_to_lteq
                            statuses_contains_array] + [s: []])
      end

      def search_params
        index_params.fetch(:q, {})
      end

      def update_params
        dup_params = domain_params.to_h.dup
        return dup_params unless dup_params[:contacts]

        modify_contact_params(dup_params)
      end

      def modify_contact_params(params)
        new_contact_params = params[:contacts].map { |c| c.to_h.symbolize_keys }
        old_contact_params = @domain.domain_contacts.includes(:contact).map do |c|
          { code: c.contact.code, type: c.name.downcase }
        end
        params[:contacts] = (new_contact_params - old_contact_params).map do |c|
          c.merge(action: 'add')
        end
        params[:contacts].concat((old_contact_params - new_contact_params)
                         .map { |c| c.merge(action: 'rem') })
        params
      end

      def domain_params
        params.require(:domain).permit(:name, :period, :period_unit, :registrar, :transfer_code,
                                       :reserved_pw, :legal_document, :registrant,
                                       legal_document: %i[body type], registrant: [%i[code verified]],
                                       dns_keys: [%i[id flags alg protocol public_key action]],
                                       nameservers: [[:id, :hostname, :action, { ipv4: [], ipv6: [] }]],
                                       contacts: [%i[code type action]],
                                       nameservers_attributes: [[:hostname, { ipv4: [], ipv6: [] }]],
                                       admin_contacts: [], tech_contacts: [],
                                       dnskeys_attributes: [%i[flags alg protocol public_key]],
                                       delete: [:verified])
      end
    end
  end
end
