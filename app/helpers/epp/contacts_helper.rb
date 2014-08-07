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
    code = params_hash['epp']['command']['update']['update'][:id]
    @contact = Contact.where(code: code).first
    if @contact.update_attributes(contact_and_address_attributes.delete_if { |k, v| v.nil? })
      render 'epp/contacts/update'
    else
      handle_errors(@contact)
    end
  end

  def delete_contact
    ph = params_hash['epp']['command']['delete']['delete']

    begin
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
    epp_errors << { code: '2303', msg: t('errors.messages.epp_obj_does_not_exist') }
    render 'epp/error'
  end

  private

  def contact_and_address_attributes
    ph = params_hash['epp']['command'][params[:command]][params[:command]]
    ph = ph[:chg] if params[:command] == 'update'
    contact_hash = {
      code: ph[:id],
      phone: ph[:voice],
      ident: ph[:ident],
      ident_type: ident_type,
      email: ph[:email],
    }

    contact_hash = contact_hash.merge({
      name: ph[:postalInfo][:name],
      org_name: ph[:postalInfo][:org]
    }) if ph[:postalInfo].is_a? Hash

    contact_hash = contact_hash.merge({
      address_attributes: {
        country_id: Country.find_by(iso: ph[:postalInfo][:addr][:cc]),
        street: tidy_street,
        zip: ph[:postalInfo][:addr][:pc]
      }
    }) if ph[:postalInfo].is_a?(Hash) && ph[:postalInfo][:addr].is_a?(Hash)

    contact_hash
  end

  def has_rights
    if @contact.created_by.registrar == current_epp_user.registrar
      return true
    end
    return false
  end

  def tidy_street
    command = params[:command]
    street = params_hash['epp']['command'][command][command][:postalInfo][:addr][:street]
    return street if street.is_a? String
    return street.join(',') if street.is_a? Array
    return nil
  rescue NoMethodError => e #refactor so wouldn't use rescue for flow control
    return nil
  end

  def ident_type
    result = params[:frame].slice(/(?<=\<ns2:ident type=)(.*)(?=<)/)

    return nil unless result

    Contact::IDENT_TYPES.any? { |type| return type if result.include?(type) }
    return nil
  end

  def handle_contact_errors # handle_errors conflicted with domain logic
    handle_epp_errors({
      '2302' => ['Contact id already exists'],
      '2303' => [:not_found, :epp_obj_does_not_exist],
      '2005' => ['Phone nr is invalid', 'Email is invalid']
    },@contact)
  end
end
