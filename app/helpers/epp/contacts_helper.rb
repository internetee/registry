module Epp::ContactsHelper
  def create_contact
    @contact = Contact.new(contact_and_address_attributes)
    render '/epp/contacts/create' and return if stamp(@contact) && @contact.save

    handle_errors(@contact)
  end

  def update_contact
    code = params_hash['epp']['command']['update']['update'][:id]
    @contact = Contact.where(code: code).first
    if rights? && stamp(@contact) && @contact.update_attributes(contact_and_address_attributes(:update))
      render 'epp/contacts/update'
    else
      contact_exists?
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
    handle_errors and return unless rights?
    @contact = find_contact
    handle_errors(@contact) and return unless @contact
    render 'epp/contacts/info'
  end

  def renew_contact
    epp_errors << { code: '2101', msg: t(:'errors.messages.unimplemented_command') }
    handle_errors
  end

  ## HELPER METHODS

  private

  ## CREATE
  def validate_contact_create_request
    @ph = params_hash['epp']['command']['create']['create']
    xml_attrs_present?(@ph, [%w(id), %w(authInfo pw), %w(postalInfo)])

    return epp_errors.empty? unless @ph['postalInfo'].is_a?(Hash) || @ph['postalInfo'].is_a?(Array)

    (epp_errors << Address.validate_postal_info_types(parsed_frame)).flatten!
    xml_attrs_array_present?(@ph['postalInfo'], [%w(name), %w(addr city), %w(addr cc)])
  end

  ## UPDATE
  def validate_contact_update_request
    @ph = params_hash['epp']['command']['update']['update']
    update_attrs_present?
    xml_attrs_present?(@ph, [['id']])
  end

  def contact_exists?
    return true if @contact.is_a?(Contact)
    epp_errors << { code: '2303', msg: t('errors.messages.epp_obj_does_not_exist'),
                    value: { obj: 'id', val: code } }
  end

  def update_attrs_present?
    return true if parsed_frame.css('add').present?
    return true if parsed_frame.css('rem').present?
    return true if parsed_frame.css('chg').present?
    epp_errors << { code: '2003', msg: I18n.t('errors.messages.required_parameter_missing', key: 'add, rem or chg') }
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
      epp_errors << { code: '2303',
                      msg: t('errors.messages.epp_obj_does_not_exist'),
                      value: { obj: 'id', val: @ph[:id] } }
    end
    contact
  end

  def rights?
    pw = @ph.try(:[], :authInfo).try(:[], :pw) || @ph.try(:[], :chg).try(:[], :authInfo).try(:[], :pw) || []

    return true if  !find_contact.nil? && find_contact.auth_info_matches(pw)

    epp_errors << { code: '2201', msg: t('errors.messages.epp_authorization_error'), value: { obj: 'pw', val: pw } }
    false
  end

  def contact_and_address_attributes(type = :create)
    case type
    when :update
      contact_hash = merge_attribute_hash(@ph[:chg], type)
    else
      contact_hash = merge_attribute_hash(@ph, type)
    end
    contact_hash[:ident_type] = ident_type unless ident_type.nil?
    contact_hash
  end

  def merge_attribute_hash(prms, type)
    contact_hash = Contact.extract_attributes(prms, type)
    contact_hash = contact_hash.merge(
      Address.extract_attributes((prms.try(:[], :postalInfo) || []))
    )
    contact_hash
  end

  def ident_type
    result = params[:frame].slice(/(?<=\<ns2:ident type=)(.*)(?=<)/)

    return nil unless result

    Contact::IDENT_TYPES.any? { |type| return type if result.include?(type) }
    nil
  end
end
