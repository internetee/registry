module Actions
  class DomainCreate
    attr_reader :domain, :params

    def initialize(domain, params)
      @domain = domain
      @params = params
    end

    def call
      assign_domain_attributes
      validate_domain_integrity
      return false if domain.errors[:epp_errors].any?

      assign_registrant
      assign_nameservers
      assign_admin_contacts
      assign_tech_contacts
      domain.attach_default_contacts
      assign_expiry_time

      commit
    end

    # Check if domain is eligible for new registration
    def validate_domain_integrity
      return unless Domain.release_to_auction

      dn = DNS::DomainName.new(SimpleIDN.to_unicode(params[:name].strip.downcase))
      if dn.at_auction?
        domain.add_epp_error('2306', nil, nil, 'Parameter value policy error: domain is at auction')
        return
      elsif dn.awaiting_payment?
        domain.add_epp_error('2003', nil, nil, 'Required parameter missing; reserved>pw element required for reserved domains')
        return
      elsif dn.pending_registration?
        if params[:reserved_pw].blank?
          domain.add_epp_error('2003', nil, nil, 'Required parameter missing; reserved>pw element is required')
        else
          unless dn.available_with_code?(params[:reserved_pw])
            domain.add_epp_error('2202', nil, nil, 'Invalid authorization information; invalid reserved>pw value')
          end
        end
      end
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
