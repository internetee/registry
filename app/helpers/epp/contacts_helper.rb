module Epp::ContactsHelper
  def create_contact
    @contact = Contact.new(contact_and_address_attributes)
    render '/epp/contacts/create' and return if stamp(@contact) && @contact.save

    handle_errors(@contact)
  end

  def update_contact
    code = params_hash['epp']['command']['update']['update'][:id]
    @contact = Contact.where(code: code).first
    if has_rights? && stamp(@contact) && @contact.update_attributes(contact_and_address_attributes(:update))
      render 'epp/contacts/update'
    else
      epp_errors << { code: '2303', msg: t('errors.messages.epp_obj_does_not_exist'), value: { obj: 'id', val: code } } if @contact == []
      handle_errors(@contact)
    end
  end

  def delete_contact
    Contact.transaction do
      @contact = find_contact
      handle_errors(@contact) and return unless @contact
      handle_errors(@contact) and return unless @contact.destroy_and_clean

      render '/epp/contacts/delete'
    end
  end

  def check_contact
    ph = params_hash['epp']['command']['check']['check']
    @contacts = Contact.check_availability(ph[:id])
    render '/epp/contacts/check'
  end

  def info_contact
    handle_errors and return unless has_rights?
    @contact = find_contact
    handle_errors(@contact) and return unless @contact
    render 'epp/contacts/info'
  end

  ## HELPER METHODS

  private

  ## CREATE
  def validate_contact_create_request
    @ph = params_hash['epp']['command']['create']['create']
    xml_attrs_present?(@ph, [['id'],
                             %w(authInfo pw),
                             %w(postalInfo name),
                             %w(postalInfo addr city),
                             %w(postalInfo addr cc)])
  end

  ## UPDATE
  def validate_contact_update_request
    @ph = params_hash['epp']['command']['update']['update']
    xml_attrs_present?(@ph, [['id']])
  end

  ## DELETE
  def validate_contact_delete_request
    @ph = params_hash['epp']['command']['delete']['delete']
    xml_attrs_present?(@ph, [['id']])
  end

  ## CHECK
  def validate_contact_check_request
    @ph = params_hash['epp']['command']['check']['check']
    xml_attrs_present?(@ph, [['id']])
  end

  ## INFO
  def validate_contact_info_request
    @ph = params_hash['epp']['command']['info']['info']
    xml_attrs_present?(@ph, [['id']])
  end

  ## SHARED

  def find_contact
    contact = Contact.find_by(code: @ph[:id])
    unless contact
      epp_errors << { code: '2303', msg: t('errors.messages.epp_obj_does_not_exist'), value: { obj: 'id', val: @ph[:id] } }
    end
    contact
  end

  def has_rights?
    pw = @ph.try(:[], :authInfo).try(:[], :pw) || @ph.try(:[], :chg).try(:[], :authInfo).try(:[], :pw) || []
    id = @ph[:id]

    return true if  !find_contact.nil? && find_contact.auth_info_matches(pw)

    epp_errors << { code: '2201', msg: t('errors.messages.epp_authorization_error'), value: { obj: 'pw', val: pw } }
    false
  end

  def contact_and_address_attributes(type = :create)
    case type
    when :update
      contact_hash = Contact.extract_attributes(@ph[:chg], type)
      contact_hash[:address_attributes] =
        Address.extract_attributes(( @ph.try(:[], :chg).try(:[], :postalInfo).try(:[], :addr) || []),  type)
    else
      contact_hash = Contact.extract_attributes(@ph, type)
      contact_hash[:address_attributes] =
        Address.extract_attributes(( @ph.try(:[], :postalInfo).try(:[], :addr) || []),  type)
    end
    contact_hash[:ident_type] = ident_type unless ident_type.nil?
    contact_hash
  end

  def ident_type
    result = params[:frame].slice(/(?<=\<ns2:ident type=)(.*)(?=<)/)

    return nil unless result

    Contact::IDENT_TYPES.any? { |type| return type if result.include?(type) }
    nil
  end
end
