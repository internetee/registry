module Epp::ContactsHelper
  def create_contact
    @contact = Contact.new(contact_and_address_attributes)
    @contact.registrar = current_epp_user.registrar
    render '/epp/contacts/create' and return if stamp(@contact) && @contact.save
    handle_errors(@contact)
  end

  def update_contact
    # FIXME: Update returns 2303 update multiple times
    code = params_hash['epp']['command']['update']['update'][:id]
    @contact = Contact.where(code: code).first
    if update_rights? && stamp(@contact) && @contact.update_attributes(contact_and_address_attributes(:update))
      render 'epp/contacts/update'
    else
      contact_exists?(code)
      handle_errors(@contact) and return
    end
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  def delete_contact
    @contact = find_contact
    handle_errors(@contact) and return unless rights? #owner?
    handle_errors(@contact) and return unless @contact
    handle_errors(@contact) and return unless @contact.destroy_and_clean

    render '/epp/contacts/delete'
  end
  # rubocop:enable Metrics/CyclomaticComplexity

  def check_contact
    ph = params_hash['epp']['command']['check']['check']
    @contacts = Contact.check_availability(ph[:id])
    render '/epp/contacts/check'
  end

  def info_contact
    handle_errors(@contact) and return unless @contact
    handle_errors(@contact) and return unless rights?
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
    return false unless validate_params
    #xml_attrs_present?(@ph, [%w(postalInfo)])
    xml_attrs_present?(@ph, [%w(postalInfo name), %w(postalInfo addr city), %w(postalInfo addr cc),
                             %w(ident), %w(voice), %w(email)])


    return epp_errors.empty? #unless @ph['postalInfo'].is_a?(Hash) || @ph['postalInfo'].is_a?(Array)

    # (epp_errors << Address.validate_postal_info_types(parsed_frame)).flatten!
    #xml_attrs_array_present?(@ph['postalInfo'], [%w(name), %w(addr city), %w(addr cc)])
  end

  ## UPDATE
  def validate_contact_update_request
    @ph = params_hash['epp']['command']['update']['update']
    update_attrs_present?
    xml_attrs_present?(@ph, [['id'], %w(authInfo pw)])
  end

  def contact_exists?(code)
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

  ## check
  def validate_contact_check_request
    @ph = params_hash['epp']['command']['check']['check']
    xml_attrs_present?(@ph, [['id']])
  end

  ## info
  def validate_contact_info_request # and process
    @ph = params_hash['epp']['command']['info']['info']
    xml_attrs_present?(@ph, [['id']])
    @contact = find_contact
    return false unless @contact
    return true if current_epp_user.registrar == @contact.registrar || xml_attrs_present?(@ph, [%w(authInfo pw)])
    false
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

  def owner?
    return false unless find_contact
    # return true if current_epp_user.registrar == find_contact.created_by.try(:registrar)
    return true if @contact.registrar == current_epp_user.registrar
    epp_errors << { code: '2201', msg: t('errors.messages.epp_authorization_error') }
    false
  end

  def rights?
    pw = @ph.try(:[], :authInfo).try(:[], :pw)

    return true if current_epp_user.try(:registrar) == @contact.try(:registrar)
    return true if pw && @contact.auth_info_matches(pw) # @contact.try(:auth_info_matches, pw)

    epp_errors << { code: '2201', msg: t('errors.messages.epp_authorization_error'), value: { obj: 'pw', val: pw } }
    false
  end

  def update_rights?
    pw = @ph.try(:[], :authInfo).try(:[], :pw)
    return true if pw && @contact.auth_info_matches(pw)
    epp_errors << { code: '2201', msg: t('errors.messages.epp_authorization_error'), value: { obj: 'pw', val: pw } }
    false
  end

  def contact_and_address_attributes(type = :create)
    case type
    when :update
      # TODO: support for rem/add
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
    contact_hash[:disclosure_attributes] =
      ContactDisclosure.extract_attributes(parsed_frame)

    contact_hash
  end

  def ident_type
    result = params[:frame].slice(/(?<=\<ns2:ident type=)(.*)(?=<)/)

    return nil unless result

    Contact::IDENT_TYPES.any? { |type| return type if result.include?(type) }
    nil
  end

  def validate_params
    return true if @ph
    epp_errors << { code: '2001', msg: t(:'errors.messages.epp_command_syntax_error') }
    false
  end
end
