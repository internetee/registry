module Epp::ContactsHelper
  def create_contact
    @contact = Contact.new( contact_and_address_attributes )
    stamp @contact
    if @contact.save
      render '/epp/contacts/create'
    else
      handle_errors(@contact)
    end
  end

  def update_contact
    #TODO add support for rem and add
    code = params_hash['epp']['command']['update']['update'][:id]
    @contact = Contact.where(code: code).first
    if stamp(@contact) && @contact.update_attributes(contact_and_address_attributes(:update))
      render 'epp/contacts/update'
    else
      epp_errors << { code: '2303', msg: t('errors.messages.epp_obj_does_not_exist'), value: { obj: 'id', val: code } } if @contact == []
      handle_errors(@contact)
    end
  end

  def delete_contact
    #no deleting, implement PaperTrail or something similar. 
    ph = params_hash['epp']['command']['delete']['delete']

    @contact = Contact.where(code: ph[:id]).first
    @contact.destroy
    render '/epp/contacts/delete'
  rescue NoMethodError => e
    epp_errors << { code: '2303', msg: t('errors.messages.epp_obj_does_not_exist') }
    render '/epp/error'
  rescue
    epp_errors << {code: '2400', msg: t('errors.messages.epp_command_failed')}
    render '/epp/error'
  end

  def check_contact
    ph = params_hash['epp']['command']['check']['check']
    @contacts = Contact.check_availability( ph[:id] )

    if @contacts.any?
      render '/epp/contacts/check'
    else
      epp_errors << { code: '2303', msg: t('errors.messages.epp_obj_does_not_exist') }
      render 'epp/error'
    end
  end

  def info_contact
    #TODO do we reject contact without authInfo or display less info?
    #TODO add data missing from contacts/info builder ( marked with 'if false' in said view )
    current_epp_user
    ph = params_hash['epp']['command']['info']['info']

    @contact = Contact.where(code: ph[:id]).first
    case has_rights
    when true
       render 'epp/contacts/info'
    when false
      epp_errors << { code: '2201', msg: t('errors.messages.epp_authorization_error') }
      render 'epp/error'
    end
  rescue NoMethodError => e
    epp_errors << { code: '2303', msg: t('errors.messages.epp_obj_does_not_exist'), value: { obj: 'id', val: ph[:id] } }
    render 'epp/error'
  end

  private

  def validate_contact_create_request
    @ph = params_hash['epp']['command']['create']['create']
    xml_attrs_present?(@ph, [['id'], 
                             ['postalInfo'], 
                             ['postalInfo', 'name'], 
                             ['postalInfo', 'addr'],
                             ['postalInfo', 'addr', 'city'], 
                             ['postalInfo', 'addr', 'cc'], 
                             ['authInfo']])
  end

  def validate_contact_update_request
    @ph = params_hash['epp']['command']['update']['update']
    xml_attrs_present?(@ph, [['id'] ])
  end

  def validate_contact_delete_request
    @ph = params_hash['epp']['command']['delete']['delete']
    xml_attrs_present?(@ph, [ ['id'] ] )
  end

  def validate_contact_check_request
    @ph = params_hash['epp']['command']['check']['check']
    xml_attrs_present?(@ph, [ ['id'] ])
  end

  def validate_contact_info_request
    @ph = params_hash['epp']['command']['info']['info']
    xml_attrs_present?(@ph, [ ['id'] ])
  end


  def contact_and_address_attributes( type=:create )
    case type
    when :update
      contact_hash = Contact.extract_attributes(@ph[:chg], type)
      contact_hash[:address_attributes] = 
        Address.extract_attributes(( @ph.try(:[], :chg).try(:[], :postalInfo).try(:[], :addr) || [] ),  type)
    else
      contact_hash = Contact.extract_attributes(@ph, type)
      contact_hash[:address_attributes] = 
        Address.extract_attributes(( @ph.try(:[], :postalInfo).try(:[], :addr) || [] ),  type)
    end
    contact_hash[:ident_type] = ident_type unless ident_type.nil?
    contact_hash
  end

  def has_rights
    if @contact.created_by.registrar == current_epp_user.registrar
      return true
    end
    return false
  end

  def ident_type
    result = params[:frame].slice(/(?<=\<ns2:ident type=)(.*)(?=<)/)

    return nil unless result

    Contact::IDENT_TYPES.any? { |type| return type if result.include?(type) }
    return nil
  end
end
