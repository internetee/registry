module Actions
  class DomainCreate # rubocop:disable Metrics/ClassLength
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
      check_for_valid_nameserver
      assign_domain_contacts
      domain.attach_default_contacts
      assign_expiry_time
      maybe_attach_legal_doc

      commit
    end

    def check_for_valid_nameserver
      nameservers_data = params[:nameservers_attributes]

      nameservers_data.each do |nameserver|
        result = parse_nameserver_hash(nameserver)

        next unless result
      end
    end

    def parse_nameserver_hash(nameserver)
      result = Domains::NameserverValidator.run(hostname: nameserver[:hostname])

      return true if result[:result]

      domain.add_epp_error('2303', nil, result[:reason], 'Problem with nameserver: ')
    end

    def check_contact_duplications
      if check_for_same_contacts(@admin_contacts, 'admin') &&
         check_for_same_contacts(@tech_contacts, 'tech')
        true
      else
        false
      end
    end

    def check_for_same_contacts(contacts, contact_type)
      return true unless contacts.uniq.count != contacts.count

      domain.add_epp_error('2306', contact_type, nil, %i[domain_contacts invalid])
      false
    end

    # Check if domain is eligible for new registration
    def validate_domain_integrity
      return unless Domain.release_to_auction

      dn = DNS::DomainName.new(domain.name)
      if dn.at_auction?
        domain.add_epp_error('2306', nil, nil, 'Parameter value policy error: domain is at auction')
      elsif dn.awaiting_payment?
        domain.add_epp_error('2003', nil, nil, 'Required parameter missing; reserved>pw element' \
        ' required for reserved domains')
      elsif dn.pending_registration?
        validate_reserved_password(dn)
      end
    end

    def validate_reserved_password(domain_name)
      if params[:reserved_pw].blank?
        domain.add_epp_error('2003', nil, nil, 'Required parameter missing; reserved>pw ' \
        'element is required')
      else
        unless domain_name.available_with_code?(params[:reserved_pw])
          domain.add_epp_error('2202', nil, nil, 'Invalid authorization information; invalid ' \
          'reserved>pw value')
        end
      end
    end

    def assign_registrant
      unless params[:registrant]
        domain.add_epp_error('2306', nil, nil, %i[registrant cannot_be_missing])
        return
      end

      regt = Registrant.find_by(code: params[:registrant])
      if regt
        domain.registrant = regt
      else
        domain.add_epp_error('2303', 'registrant', params[:registrant], %i[registrant not_found])
      end
    end

    def assign_domain_attributes
      domain.name = params[:name].strip.downcase
      domain.registrar = current_registrar
      assign_domain_period
      assign_domain_auth_codes
      assign_dnskeys
    end

    def assign_dnskeys
      return unless params[:dnskeys_attributes]&.any?

      params[:dnskeys_attributes].each { |dk| verify_public_key_integrity(dk[:public_key]) }
      domain.dnskeys_attributes = params[:dnskeys_attributes]
    end

    def verify_public_key_integrity(pub)
      return if Dnskey.pub_key_base64?(pub)

      domain.add_epp_error(2005, nil, nil, %i[dnskeys invalid])
    end

    def assign_domain_auth_codes
      domain.transfer_code = params[:transfer_code] if params[:transfer_code].present?
      domain.reserved_pw = params[:reserved_pw] if params[:reserved_pw].present?
    end

    def assign_domain_period
      domain.period = params[:period].to_i
      domain.period_unit = params[:period_unit]
    end

    def assign_nameservers
      return unless params[:nameservers_attributes]

      domain.nameservers_attributes = params[:nameservers_attributes]
    end

    def assign_contact(contact_code, admin: true)
      contact = Contact.find_by(code: contact_code)
      arr = admin ? @admin_contacts : @tech_contacts
      if contact
        arr << { contact_id: contact.id, contact_code_cache: contact.code }
      else
        domain.add_epp_error('2303', 'contact', contact_code, %i[domain_contacts not_found])
      end
    end

    def assign_domain_contacts
      @admin_contacts = []
      @tech_contacts = []
      params[:admin_contacts]&.each { |c| assign_contact(c) }
      params[:tech_contacts]&.each { |c| assign_contact(c, admin: false) }

      domain.admin_domain_contacts_attributes = @admin_contacts
      domain.tech_domain_contacts_attributes = @tech_contacts
      check_contact_duplications
    end

    def assign_expiry_time
      return unless domain.period

      period = Integer(domain.period)
      domain.expire_time = calculate_expiry(period)
    end

    def calculate_expiry(period)
      plural_period_unit_name = (domain.period_unit == 'm' ? 'months' : 'years').to_sym
      (Time.zone.now.advance(plural_period_unit_name => period) + 1.day).beginning_of_day
    end

    def action_billable?
      unless domain_pricelist&.price
        domain.add_epp_error(2104, nil, nil, I18n.t(:active_price_missing_for_this_operation))
        return false
      end

      if domain.registrar.balance < domain_pricelist.price.amount
        domain.add_epp_error(2104, nil, nil, I18n.t('billing_failure_credit_balance_low'))
        return false
      end

      true
    end

    def debit_registrar
      return unless action_billable?

      domain.registrar.debit!(sum: domain_pricelist.price.amount, price: domain_pricelist,
                              description: "#{I18n.t('create')} #{domain.name}",
                              activity_type: AccountActivity::CREATE)
    end

    def domain_pricelist
      @domain_pricelist ||= domain.pricelist('create', domain.period.try(:to_i), domain.period_unit)

      @domain_pricelist
    end

    def maybe_attach_legal_doc
      ::Actions::BaseAction.attach_legal_doc_to_new(domain, params[:legal_document], domain: true)
    end

    def process_auction_and_disputes
      dn = DNS::DomainName.new(domain.name)
      Dispute.close_by_domain(domain.name)
      return unless Domain.release_to_auction && dn.pending_registration?

      Auction.find_by(domain: domain.name,
                      status: Auction.statuses[:payment_received])&.domain_registered!
    end

    def commit
      return false if domain.errors[:epp_errors].any? || validation_process_errored?

      debit_registrar
      return false if domain.errors.any?

      process_auction_and_disputes
      domain.save
    end

    def validation_process_errored?
      return if domain.valid?

      domain.errors.delete(:name_dirty) if domain.errors[:puny_label].any?
      domain.errors.any?
    end

    def current_registrar
      Registrar.find(params[:registrar])
    end
  end
end
