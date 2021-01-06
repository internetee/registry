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
      assign_new_registrant if params[:registrant]
      assign_nameserver_modifications if params[:nameservers]
      assign_admin_contact_changes if params[:contacts]
      assign_tech_contact_changes if params[:contacts]
      assign_requested_statuses if params[:statuses]
      assign_dnssec_modifications if params[:dns_keys]
      maybe_attach_legal_doc

      commit
    end

    def validate_domain_integrity
      domain.auth_info = params[:auth_info] if params[:auth_info]

      return unless domain.discarded?

      domain.add_epp_error('2304', nil, nil, 'Object status prohibits operation')
    end

    def assign_new_registrant
      unless params[:registrant][:code]
        domain.add_epp_error('2306', nil, nil, %i[registrant cannot_be_missing])
      end

      regt = Registrant.find_by(code: params[:registrant][:code])
      unless regt
        domain.add_epp_error('2303', 'registrant', params[:registrant_id], %i[registrant not_found])
        return
      end

      replace_domain_registrant(regt)
    end

    def replace_domain_registrant(new_registrant)
      return if domain.registrant == new_registrant

      @changes_registrant = true if domain.registrant.ident != new_registrant.ident
      domain.registrant = new_registrant
    end

    def assign_nameserver_modifications
      @nameservers = []
      params[:nameservers].each do |ns_attr|
        case ns_attr[:action]
        when 'rem'
          validate_ns_integrity(ns_attr)
        when 'add'
          @nameservers << ns_attr.except(:action)
        end
      end

      domain.nameservers_attributes = @nameservers if @nameservers.present?
    end

    def validate_ns_integrity(ns_attr)
      ns = domain.nameservers.find_by_hash_params(ns_attr.except(:action)).first
      if ns
        @nameservers << { id: ns.id, _destroy: 1 }
      else
        domain.add_epp_error('2303', 'hostAttr', ns_attr[:hostname], %i[nameservers not_found])
      end
    end

    def assign_dnssec_modifications
      @dnskeys = []

      params[:dns_key].each do |key|
        case key[:action]
        when 'add'
          validate_dnskey_integrity(key) && dnskeys << key.except(:action)
        when 'rem'
          assign_removable_dnskey(key)
        end
      end

      domain.dnskeys_attributes = dnskeys
    end

    def validate_dnskey_integrity(key)
      if key[:pubKey] && !Setting.key_data_allowed
        domain.add_epp_error('2306', nil, nil, %i[dnskeys key_data_not_allowed])
      elsif key[:digest] && !Setting.ds_data_allowed
        domain.add_epp_error('2306', nil, nil, %i[dnskeys ds_data_not_allowed])
      end

      dnskeys << key.except(:action)
    end

    def assign_removable_dnskey(key)
      dnkey = domain.dnskeys.find_by(key.except(:action))
      domain.add_epp_error('2303', nil, nil, %i[dnskeys not_found]) unless dnkey

      @dnskeys << { id: dnkey.id, _destroy: 1 } if dnkey
    end

    def assign_admin_contact_changes
      props = gather_domain_contacts(params[:contacts].select { |c| c[:type] == 'admin' })

      if props.any? && domain.admin_change_prohibited?
        domain.add_epp_error('2304', 'admin', DomainStatus::SERVER_ADMIN_CHANGE_PROHIBITED,
                             I18n.t(:object_status_prohibits_operation))
      elsif props.present?
        domain.admin_domain_contacts_attributes = props
      end
    end

    def assign_tech_contact_changes
      props = gather_domain_contacts(params[:contacts].select { |c| c[:type] == 'tech' },
                                     admin: false)

      if props.any? && domain.tech_change_prohibited?
        domain.add_epp_error('2304', 'tech', DomainStatus::SERVER_TECH_CHANGE_PROHIBITED,
                             I18n.t(:object_status_prohibits_operation))
      elsif props.present?
        domain.tech_domain_contacts_attributes = props
      end
    end

    def gather_domain_contacts(contacts, admin: true)
      props = []

      contacts.each do |c|
        contact = contact_for_action(action: c[:action], method: admin ? 'admin' : 'tech',
                                     code: c[:code])
        entry = assign_contact(contact, add: c[:action] == 'add', admin: admin)
        props << entry if entry.is_a?(Hash)
      end

      props
    end

    def contact_for_action(action:, method:, code:)
      return Epp::Contact.find_by(code: code) if action == 'add'
      return domain.admin_domain_contacts.find_by(contact_code_cache: code) if method == 'admin'

      domain.tech_domain_contacts.find_by(contact_code_cache: code)
    end

    def assign_contact(obj, add: false, admin: true)
      if obj.blank?
        domain.add_epp_error('2303', 'contact', obj[:code], %i[domain_contacts not_found])
      elsif obj.org? && admin
        domain.add_epp_error('2306', 'contact', obj[:code],
                             %i[domain_contacts admin_contact_can_be_only_private_person])
      else
        add ? { contact_id: obj.id, contact_code_cache: obj.code } : { id: obj.id, _destroy: 1 }
      end
    end

    def assign_requested_statuses
      rem = []
      add = []

      params[:statuses].each do |s|
        status, action = s.slice(:status, :action)
        if permitted_status?(status, action)
          action == 'add' ? add << status : rem << action
        end
      end

      domain.statuses = domain.statuses - rem + add unless domain.errors.any?
    end

    def permitted_status?(status, action)
      if DomainStatus::CLIENT_STATUSES.include?(status) &&
         (domain.statuses.include?(status) || action == 'add')

        true
      else
        domain.add_epp_error('2303', 'status', s[:status], %i[statuses not_found])
        false
      end
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
          domain.add_epp_error('2202', nil, nil,
                               'Invalid authorization information; invalid reserved>pw value')
        end
      else
        domain.add_epp_error('2304', nil, nil, 'Required parameter missing; reservedpw element ' \
        'required for dispute domains')
      end

      true
    end

    def maybe_attach_legal_doc
      Actions::BaseAction.maybe_attach_legal_doc(domain, params[:legal_document])
    end

    def commit
      return false if domain.errors[:epp_errors].any?
      return false unless domain.valid?

      if verify_registrant_change? && !bypass_verify &&
         Setting.request_confirmation_on_registrant_change_enabled && !bypass_verify

        domain.registrant_verification_asked!(params, params[:registrar_id])
      end

      return false if domain.errors[:epp_errors].any?
      return false unless domain.valid?

      domain.save
    end
  end
end
