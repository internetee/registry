module Actions
  class DomainUpdate # rubocop:disable Metrics/ClassLength
    attr_reader :domain, :params, :bypass_verify

    def initialize(domain, params, bypass_verify)
      @domain = domain
      @params = params
      @bypass_verify = bypass_verify
      @changes_registrant = false
    end

    def call
      validate_domain_integrity
      assign_new_registrant if params[:registrant]
      assign_relational_modifications
      assign_requested_statuses

      ::Actions::BaseAction.maybe_attach_legal_doc(domain, params[:legal_document])

      commit
    end

    def assign_relational_modifications
      assign_nameserver_modifications if params[:nameservers]
      assign_dnssec_modifications if params[:dns_keys]
      return unless params[:contacts]

      assign_admin_contact_changes
      assign_tech_contact_changes
    end

    def check_for_same_contacts(contacts, contact_type)
      return unless contacts.uniq.count != contacts.count

      domain.add_epp_error('2306', contact_type, nil, %i[domain_contacts invalid])
    end

    def validate_domain_integrity
      domain.auth_info = params[:transfer_code] if params[:transfer_code]

      return unless domain.discarded?

      domain.add_epp_error('2304', nil, nil, 'Object status prohibits operation')
    end

    def assign_new_registrant
      domain.add_epp_error('2306', nil, nil, %i[registrant cannot_be_missing]) unless params[:registrant][:code]

      contact_code = params[:registrant][:code]
      contact = Contact.find_by(code: contact_code)
      validate_email(contact.email)

      regt = Registrant.find_by(code: params[:registrant][:code])
      unless regt
        domain.add_epp_error('2303', 'registrant', params[:registrant], %i[registrant not_found])
        return
      end

      replace_domain_registrant(regt)
    end

    def replace_domain_registrant(new_registrant)
      return if domain.registrant == new_registrant

      @changes_registrant = true if domain.registrant.ident != new_registrant.ident
      if @changes_registrant && domain.registrant_change_prohibited?
        domain.add_epp_error(2304, 'status', DomainStatus::SERVER_REGISTRANT_CHANGE_PROHIBITED,
                             I18n.t(:object_status_prohibits_operation))
      else
        domain.registrant = new_registrant
      end
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
      ns = domain.nameservers.from_hash_params(ns_attr.except(:action)).first
      if ns
        @nameservers << { id: ns.id, _destroy: 1 }
      else
        domain.add_epp_error('2303', 'hostAttr', ns_attr[:hostname], %i[nameservers not_found])
      end
    end

    def assign_dnssec_modifications
      @dnskeys = []
      params[:dns_keys].each do |key|
        case key[:action]
        when 'add'
          validate_dnskey_integrity(key)
        when 'rem'
          assign_removable_dnskey(key)
        end
      end

      domain.dnskeys_attributes = @dnskeys.uniq
    end

    def validate_dnskey_integrity(key)
      if key[:public_key] && !Setting.key_data_allowed
        domain.add_epp_error('2306', nil, nil, %i[dnskeys key_data_not_allowed])
      elsif Dnskey.pub_key_base64?(key[:public_key])
        @dnskeys << key.except(:action)
      else
        domain.add_epp_error(2005, nil, nil, %i[dnskeys invalid])
      end
    end

    def assign_removable_dnskey(key)
      dnkey = domain.dnskeys.find_by(key.except(:action))
      domain.add_epp_error(2303, nil, nil, %i[dnskeys not_found]) unless dnkey

      @dnskeys << { id: dnkey.id, _destroy: 1 } if dnkey
    end

    def start_validate_email(props)
      contact = Contact.find_by(code: props[0][:contact_code])

      return if contact.nil?

      validate_email(contact.email)
    end

    def validate_email(email)
      return true if Rails.env.test?

      %i[regex mx].each do |m|
        result = Actions::SimpleMailValidator.run(email: email, level: m)
        next if result

        err_text = "email #{email} didn't pass validation"
        domain.add_epp_error('2005', nil, nil, "#{I18n.t(:parameter_value_syntax_error)} #{err_text}")
        @error = true
        return
      end

      true
    end

    def assign_admin_contact_changes
      props = gather_domain_contacts(params[:contacts].select { |c| c[:type] == 'admin' })

      start_validate_email(props) if props.present?

      if props.any? && domain.admin_change_prohibited?
        domain.add_epp_error('2304', 'admin', DomainStatus::SERVER_ADMIN_CHANGE_PROHIBITED,
                             I18n.t(:object_status_prohibits_operation))
      elsif props.present?
        domain.admin_domain_contacts_attributes = props
        check_for_same_contacts(props, 'admin')
      end
    end

    def assign_tech_contact_changes
      props = gather_domain_contacts(params[:contacts].select { |c| c[:type] == 'tech' },
                                     admin: false)

      start_validate_email(props) if props.present?

      if props.any? && domain.tech_change_prohibited?
        domain.add_epp_error('2304', 'tech', DomainStatus::SERVER_TECH_CHANGE_PROHIBITED,
                             I18n.t(:object_status_prohibits_operation))
      elsif props.present?
        domain.tech_domain_contacts_attributes = props
        check_for_same_contacts(props, 'tech')
      end
    end

    def gather_domain_contacts(contacts, admin: true)
      props = []

      contacts.each do |c|
        contact = contact_for_action(action: c[:action], method: admin ? 'admin' : 'tech',
                                     code: c[:code])
        entry = assign_contact(contact, add: c[:action] == 'add', admin: admin, code: c[:code])
        props << entry if entry.is_a?(Hash)
      end

      props
    end

    def contact_for_action(action:, method:, code:)
      contact = Epp::Contact.find_by(code: code)
      return contact if action == 'add' || !contact
      return domain.admin_domain_contacts.find_by(contact_id: contact.id) if method == 'admin'

      domain.tech_domain_contacts.find_by(contact_id: contact.id)
    end

    def assign_contact(obj, add: false, admin: true, code:)
      if obj.blank?
        domain.add_epp_error('2303', 'contact', code, %i[domain_contacts not_found])
      elsif obj.try(:org?) && admin && add
        domain.add_epp_error('2306', 'contact', code,
                             %i[domain_contacts admin_contact_can_be_only_private_person])
      else
        add ? { contact_id: obj.id, contact_code: obj.code } : { id: obj.id, _destroy: 1 }
      end
    end

    def assign_requested_statuses
      return unless params[:statuses]

      @rem = []
      @add = []
      @failed = false

      params[:statuses].each { |s| verify_status_eligiblity(s) }
      domain.statuses = (domain.statuses - @rem + @add) unless @failed
    end

    def verify_status_eligiblity(status_entry)
      status, action = status_entry.select_keys(:status, :action)
      return unless permitted_status?(status, action)

      action == 'add' ? @add << status : @rem << status
    end

    def permitted_status?(status, action)
      if DomainStatus::CLIENT_STATUSES.include?(status) &&
         (domain.statuses.include?(status) || action == 'add')
        return true
      end

      domain.add_epp_error('2303', 'status', status, %i[statuses not_found])
      @failed = true
      false
    end

    def verify_registrant_change?
      return validate_dispute_case if params[:reserved_pw]
      return false if !@changes_registrant || true?(params[:registrant][:verified])
      return true unless domain.disputed?

      domain.add_epp_error('2304', nil, nil, 'Required parameter missing; reservedpw element ' \
                           'required for dispute domains')

      true
    end

    def validate_dispute_case
      dispute = Dispute.active.find_by(domain_name: domain.name, password: params[:reserved_pw])
      if dispute
        Dispute.close_by_domain(domain.name)
        false
      else
        domain.add_epp_error('2202', nil, nil,
                             'Invalid authorization information; invalid reserved>pw value')
        true
      end
    end

    def ask_registrant_verification
      if verify_registrant_change? && !bypass_verify &&
         Setting.request_confirmation_on_registrant_change_enabled
        domain.registrant_verification_asked!(params, params[:registrar])
      end
    end

    def commit
      return false if any_errors?

      ask_registrant_verification
      return false if any_errors?

      domain.save
    end

    def any_errors?
      return true if domain.errors[:epp_errors].any? || domain.invalid?

      false
    end

    def true?(obj)
      obj.to_s.downcase == 'true'
    end
  end
end
