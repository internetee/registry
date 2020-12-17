module Actions
  class DomainUpdate
    attr_reader :domain, :params, :bypass_verify

    def initialize(domain, params, bypass_verify)
      @domain = domain
      @params = params
      @bypass_verify = bypass_verify
    end

    def call
      @changes_registrant = false

      validate_domain_integrity
      assign_new_registrant
      assign_nameserver_modifications
      assign_admin_contact_changes
      assign_tech_contact_changes
      assign_requested_statuses
      assign_dnssec_modifications

      commit
    end

    def validate_domain_integrity
      domain.auth_info = params[:auth_info] if params[:auth_info]

      return unless domain.discarded?

      domain.add_epp_error('2304', nil, nil, 'Object status prohibits operation')
    end

    def assign_new_registrant
      return unless params[:registrant]

      domain.add_epp_error('2306', nil, nil, %i[registrant cannot_be_missing]) unless params[:registrant][:code]
      regt = Registrant.find_by(code: params[:registrant][:code])
      if regt.present?
        return if domain.registrant == regt

        @changes_registrant = true if domain.registrant.ident != regt.ident
        domain.registrant = regt
      else
        domain.add_epp_error('2303', 'registrant', params[:registrant_id], %i[registrant not_found])
      end
    end

    def assign_nameserver_modifications
      return unless params[:nameservers]

      nameservers = []
      params[:nameservers].select { |ns| ns[:action] == 'rem' }.each do |ns_attr|
        ns = domain.nameservers.find_by_hash_params(ns_attr.except(:action)).first
        domain.add_epp_error('2303', 'hostAttr', ns_attr[:hostname], %i[nameservers not_found]) and break unless ns
        nameservers << { id: ns.id, _destroy: 1 }
      end

      params[:nameservers].select { |ns| ns[:action] == 'add' }.each do |ns_attr|
        nameservers << ns_attr.except(:action)
      end

      return unless nameservers.present?

      domain.nameservers_attributes = nameservers
    end

    def assign_dnssec_modifications
      dnskeys = []
      params[:dns_keys].select { |dk| dk[:action] == 'rem' }.each do |key|
        dnkey = domain.dnskeys.find_by(key.except(:action))
        domain.add_epp_error('2303', nil, nil, %i[dnskeys not_found]) unless dnkey
        dnskeys << { id: dnkey.id, _destroy: 1 } if dnkey
      end

      params[:dns_keys].select { |dk| dk[:action] == 'add' }.each do |key|
        dnskeys << key.except(:action)
      end

      domain.dnskeys_attributes = dnskeys
    end

    def assign_admin_contact_changes
      return unless params[:contacts]

      props = []
      contacts = params[:contacts].select { |c| c[:type] == 'admin' }

      if contacts.present? && domain.admin_change_prohibited?
        domain.add_epp_error('2304', 'admin', DomainStatus::SERVER_ADMIN_CHANGE_PROHIBITED, I18n.t(:object_status_prohibits_operation))
        return
      end

      contacts.select { |c| c[:action] == 'rem' }.each do |c|
        dc = domain.admin_domain_contacts.find_by(contact_code_cache: c[:code])
        if dc.present?
          props << { id: dc.id, _destroy: 1 }
        else
          domain.add_epp_error('2303', 'contact', c[:code], %i[domain_contacts not_found])
        end
      end

      contacts.select { |c| c[:action] == 'add' }.each do |c|
        contact = Epp::Contact.find_by_epp_code(c[:code])
        if contact.present?
          if contact.org?
            domain.add_epp_error('2306', 'contact', c[:code], %i[domain_contacts admin_contact_can_be_only_private_person])
          else
            props << { contact_id: contact.id, contact_code_cache: contact.code }
          end
        else
          domain.add_epp_error('2303', 'contact', c[:code], %i[domain_contacts not_found])
        end
      end

      return unless props.present?

      domain.admin_domain_contacts_attributes = props
    end

    def assign_tech_contact_changes
      return unless params[:contacts]

      props = []
      contacts = params[:contacts].select { |c| c[:type] == 'tech' }

      if contacts.present? && domain.tech_change_prohibited?
        domain.add_epp_error('2304', 'tech', DomainStatus::SERVER_TECH_CHANGE_PROHIBITED, I18n.t(:object_status_prohibits_operation))
        return
      end

      contacts.select { |c| c[:action] == 'rem' }.each do |c|
        dc = domain.tech_domain_contacts.find_by(contact_code_cache: c[:code])
        if dc.present?
          props << { id: dc.id, _destroy: 1 }
        else
          domain.add_epp_error('2303', 'contact', c[:code], %i[domain_contacts not_found])
        end
      end

      contacts.select { |c| c[:action] == 'add' }.each do |c|
        contact = Epp::Contact.find_by_epp_code(c[:code])
        if contact.present?
          props << { contact_id: contact.id, contact_code_cache: contact.code }
        else
          domain.add_epp_error('2303', 'contact', c[:code], %i[domain_contacts not_found])
        end
      end

      return unless props.present?

      domain.tech_domain_contacts_attributes = props
    end

    def assign_requested_statuses
      return unless params[:statuses]

      rem = []
      add = []

      invalid = false
      params[:statuses].each do |s|
        unless DomainStatus::CLIENT_STATUSES.include?(s[:status])
          domain.add_epp_error('2303', 'status', s[:status], %i[domain_statuses not_found])
          invalid = true
        end
      end

      params[:statuses].select { |s| s[:action] == 'rem' }.each do |s|
        if domain.statuses.include?(s[:status])
          rem << s[:status]
        else
          domain.add_epp_error('2303', 'status', s[:status], %i[domain_statuses not_found])
          invalid = true
        end
      end

      params[:statuses].select { |s| s[:action] == 'add' }.each { |s| add << s[:status] }
      return if invalid

      domain.statuses = domain.statuses - rem + add
    end

    def verify_registrant_change?
      return false unless @changes_registrant
      return false if params[:registrant][:verified] == true
      return true unless domain.disputed?

      if params[:reserved_pw]
        dispute = Dispute.active.find_by(domain_name: domain.name, password: params[:reserved_pw])
        if dispute
          Dispute.close_by_domain(domain.name)
          return false
        else
          domain.add_epp_error('2202', nil, nil, 'Invalid authorization information; invalid reserved>pw value')
        end
      else
        domain.add_epp_error('2304', nil, nil, 'Required parameter missing; reservedpw element required for dispute domains')
      end

      true
    end

    def maybe_attach_legal_doc
      return unless legal_document

      doc = LegalDocument.create(
        documentable_type: Contact,
        document_type: legal_document[:type], body: legal_document[:body]
      )

      contact.legal_documents = [doc]
      contact.legal_document_id = doc.id
    end

    def commit
      return false if domain.errors[:epp_errors].any?
      return false unless domain.valid?

      if verify_registrant_change? && Setting.request_confirmation_on_registrant_change_enabled
        return if bypass_verify

        domain.registrant_verification_asked!(params.to_s, params[:registrar_id])
      end

      return false if domain.errors[:epp_errors].any?
      return false unless domain.valid?

      domain.save
    end
  end
end
