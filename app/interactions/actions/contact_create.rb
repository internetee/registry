module Actions
  class ContactCreate
    attr_reader :contact, :legal_document, :ident, :result

    def initialize(contact, legal_document, ident)
      @contact = contact
      @legal_document = legal_document
      @ident = ident
      @result = nil
    end

    def call
      maybe_remove_address
      maybe_attach_legal_doc
      validate_ident
      maybe_change_email
      maybe_company_is_relevant
      commit
      validate_contact
    end

    def maybe_change_email
      return if Rails.env.test?

      %i[regex mx].each do |m|
        @result = Actions::SimpleMailValidator.run(email: contact.email, level: m)
        next if @result

        err_text = "email '#{contact.email}' didn't pass validation"
        contact.add_epp_error('2005', nil, nil, "#{I18n.t(:parameter_value_syntax_error)} #{err_text}")
        @error = true
        return
      end

      true
    end

    def maybe_remove_address
      return if Contact.address_processing?

      contact.city = nil
      contact.zip = nil
      contact.street = nil
      contact.state = nil
      contact.country_code = nil
    end

    def validate_ident
      validate_ident_integrity
      validate_ident_birthday

      identifier = ::Contact::Ident.new(code: ident[:ident], type: ident[:ident_type],
                                        country_code: ident[:ident_country_code])

      identifier.validate
      contact.identifier = identifier
    end

    def validate_ident_integrity
      return if ident.blank?

      if ident[:ident_type].blank?
        contact.add_epp_error('2003', nil, 'ident_type',
                              I18n.t('errors.messages.required_ident_attribute_missing'))
        @error = true
      elsif !%w[priv org birthday].include?(ident[:ident_type])
        contact.add_epp_error('2003', nil, 'ident_type', 'Invalid ident type')
        @error = true
      end
    end

    def validate_ident_birthday
      return if ident.blank?
      return unless ident[:ident_type] != 'birthday' && ident[:ident_country_code].blank?

      contact.add_epp_error('2003', nil, 'ident_country_code',
                            I18n.t('errors.messages.required_ident_attribute_missing'))
      @error = true
    end

    def maybe_company_is_relevant
      return true unless contact.org?

      if contact.ident.blank?
        contact.add_epp_error('2003', nil, 'ident', "#{I18n.t('errors.messages.required_ident_attribute_missing')}\n #{contact.inspect}")
        @error = true
        return
      end

      company_status = contact.return_company_status
      return if [Contact::REGISTERED, Contact::LIQUIDATED].include? company_status

      contact.add_epp_error('2003', nil, 'ident', I18n.t('errors.messages.company_not_registered'))
      @error = true
    end

    def maybe_attach_legal_doc
      ::Actions::BaseAction.attach_legal_doc_to_new(contact, legal_document, domain: false)
    end

    def commit
      contact.id = nil # new record
      return false if @error

      contact.generate_code
      contact.email_history = contact.email
      contact.save
    end

    def validate_contact
      return if @error || !contact.valid?

      [:regex, :mx].each do |m|
        contact.verify_email(check_level: m, single_email: true)
      end
    end
  end
end
