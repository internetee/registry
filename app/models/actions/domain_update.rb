module Actions
  class DomainCreate
    attr_reader :domain, :params

    def initialize(domain, params)
      @domain = domain
      @params = params
    end

    def call
      validate_domain_integrity
      verify_registrant_change # Should be last step
      assign_admin_contact_changes if params[:contacts]
      assign_tech_contact_changes if params[:contacts]
    end

    def validate_domain_integrity
      return unless domain.discarded?

      domain.add_epp_error('2304', nil, nil, 'Object status prohibits operation')
    end

    def assign_admin_contact_changes
      props = []
      contacts = params[:contacts].select { |c| c[:type] == 'admin' }

      if contacts.present? && domain.admin_change_prohibited?
        domain.add_epp_error('2304', 'admin', DomainStatus::SERVER_ADMIN_CHANGE_PROHIBITED, I18n.t(:object_status_prohibits_operation))
        return
      end

      contacts.select { |c| c[:action] == 'rem' }.each do |c|
        dc = domain.admin_domain_contacts.find_by(contact_code_cache: c[:code])
        domain.add_epp_error('2303', 'contact', at[:contact_code_cache], [:domain_contacts, :not_found]) and break unless dc

        props << { id: dc.id, _destroy: 1 }
      end

      contacts.select { |c| c[:action] == 'add' }.each do |c|
        contact = Epp::Contact.find_by_epp_code(c[:code])
        domain.add_epp_error('2303', 'contact', c[:code], [:domain_contacts, :not_found]) and break unless contact
        domain.add_epp_error('2306', 'contact', c[:code], [:domain_contacts, :admin_contact_can_be_only_private_person]) and break if contact.org?

        props << { id: contact.id, code: contact.code }
      end

      domain.admin_domain_contacts_attributes = props
    end

    def assign_tech_contact_changes
      props = []
      contacts = params[:contacts].select { |c| c[:type] == 'admin' }

      if contacts.present? && domain.admin_change_prohibited?
        domain.add_epp_error('2304', 'admin', DomainStatus::SERVER_ADMIN_CHANGE_PROHIBITED, I18n.t(:object_status_prohibits_operation))
        return
      end

      contacts.select { |c| c[:action] == 'rem' }.each do |c|
        dc = domain.admin_domain_contacts.find_by(contact_code_cache: c[:code])
        domain.add_epp_error('2303', 'contact', at[:contact_code_cache], [:domain_contacts, :not_found]) and break unless dc

        props << { id: dc.id, _destroy: 1 }
      end

      contacts.select { |c| c[:action] == 'add' }.each do |c|
        contact = Epp::Contact.find_by_epp_code(c[:code])
        domain.add_epp_error('2303', 'contact', c[:code], [:domain_contacts, :not_found]) and break unless contact
        domain.add_epp_error('2306', 'contact', c[:code], [:domain_contacts, :admin_contact_can_be_only_private_person]) and break if contact.org?

        props << { id: contact.id, code: contact.code }
      end

      domain.admin_domain_contacts_attributes = props
    end

    def verify_registrant_change
      return if !params[:registrant] || domain.registrant.code == params[:registrant][:code]

      if domain.disputed?
        domain.add_epp_error('2304', nil, nil, 'Required parameter missing; reservedpw element required for dispute domains') and return unless params[:reserved_pw]
        dispute = Dispute.active.find_by(domain_name: name, password: params[:reserved_pw])
        domain.add_epp_error('2202', nil, nil, 'Invalid authorization information; invalid reserved>pw value') and return unless dispute
        Dispute.close_by_domain(name)
      end

      return unless params[:registrant][:verified] && Setting.request_confirmation_on_registrant_change_enabled

      domain.registrant_verification_asked!(frame.to_s, current_user.id)
    end

    def assign_registrant
      domain.add_epp_error('2306', nil, nil, %i[registrant cannot_be_missing]) and return unless params[:registrant_id]

      regt = Registrant.find_by(code: params[:registrant_id])
      domain.add_epp_error('2303', 'registrant', params[:registrant_id], %i[registrant not_found]) and return unless regt

      domain.registrant = regt
    end

    def assign_domain_attributes
      domain.name = params[:name].strip.downcase
      domain.registrar = Registrar.find(params[:registrar_id])
      domain.period = params[:period]
      domain.period_unit = params[:period_unit]
      domain.transfer_code = params[:transfer_code] if params[:transfer_code].present?
      domain.reserved_pw = params[:reserved_pw] if params[:reserved_pw].present?
      domain.dnskeys_attributes = params[:dnskeys_attributes]
    end

    def assign_nameservers
      domain.nameservers_attributes = params[:nameservers_attributes]
    end

    def assign_admin_contacts
      attrs = []
      params[:admin_domain_contacts_attributes].each do |c|
        contact = Contact.find_by(code: c)
        domain.add_epp_error('2303', 'contact', c, %i[domain_contacts not_found]) unless contact.present?
        attrs << { contact_id: contact.id, contact_code_cache: contact.code } if contact
      end

      domain.admin_domain_contacts_attributes = attrs
    end

    def assign_tech_contacts
      attrs = []
      params[:tech_domain_contacts_attributes].each do |c|
        contact = Contact.find_by(code: c)
        domain.add_epp_error('2303', 'contact', c, %i[domain_contacts not_found]) unless contact.present?
        attrs << { contact_id: contact.id, contact_code_cache: contact.code } if contact
      end

      domain.tech_domain_contacts_attributes = attrs
    end

    def assign_expiry_time
      period = domain.period.to_i
      plural_period_unit_name = (domain.period_unit == 'm' ? 'months' : 'years').to_sym
      expire_time = (Time.zone.now.advance(plural_period_unit_name => period) + 1.day).beginning_of_day
      domain.expire_time = expire_time
    end

    def debit_registrar
      @domain_pricelist ||= domain.pricelist('create', domain.period.try(:to_i), domain.period_unit)
      if @domain_pricelist.try(:price) && domain.registrar.balance < @domain_pricelist.price.amount
        domain.add_epp_error(2104, nil, nil, I18n.t('billing_failure_credit_balance_low'))
        return
      elsif !@domain_pricelist.try(:price)
        domain.add_epp_error(2104, nil, nil, I18n.t(:active_price_missing_for_this_operation))
        return
      end

      domain.registrar.debit!({ sum: @domain_pricelist.price.amount, price: @domain_pricelist,
                                description: "#{I18n.t('create')} #{domain.name}",
                                activity_type: AccountActivity::CREATE })
    end

    def process_auction_and_disputes
      dn = DNS::DomainName.new(SimpleIDN.to_unicode(params[:name]))
      Dispute.close_by_domain(domain.name)
      return unless Domain.release_to_auction && dn.pending_registration?

      auction = Auction.find_by(domain: domain.name, status: Auction.statuses[:payment_received])
      auction.domain_registered!
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
      unless domain.valid?
        domain.errors.delete(:name_dirty) if domain.errors[:puny_label].any?
        return false if domain.errors.any?
      end
      # @domain.add_legal_file_to_new(params[:parsed_frame])
      debit_registrar

      return false if domain.errors.any?

      process_auction_and_disputes
      domain.save
    end
  end
end
