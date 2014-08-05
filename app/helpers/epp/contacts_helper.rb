module Epp::ContactsHelper
  def create_contact
    ph = params_hash['epp']['command']['create']['create']
    #todo, remove the first_or_initialize logic, since it's redundant due to 
    #<contact:id> from EPP api

    @contact = Contact.new
    @contact = Contact.where(ident: ph[:ident]).first_or_initialize( new_contact_info ) if ph[:ident]

    @contact.assign_attributes(name: ph[:postalInfo][:name])

    @contact.addresses << new_address
    stamp @contact

    @contact.save

    render '/epp/contacts/create'
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
      render '/epp/contacts/info'
    when false
      epp_errors << { code: '2201', msg: t('errors.messages.epp_authorization_error') }
      render 'epp/error'
    end
  rescue NoMethodError => e
    epp_errors << { code: '2303', msg: t('errors.messages.epp_obj_does_not_exist') }
    render 'epp/error'
  end

  private

  def has_rights
    if @contact.created_by.registrar == current_epp_user.registrar
      return true
    end
    return false
  end

  def new_address
    ph = params_hash['epp']['command']['create']['create']

    Address.new(
      country_id: Country.find_by(iso: ph[:postalInfo][:addr][:cc]),
      street: tidy_street,
      zip: ph[:postalInfo][:addr][:pc]
    )
  end

  def new_contact_info
    ph = params_hash['epp']['command']['create']['create']
    {
        code: ph[:id],
        phone: ph[:voice],
        ident: ph[:ident],
        ident_type: ident_type,
        email: ph[:email],
        org_name: ph[:postalInfo][:org]
    }
  end

  def tidy_street
    street = params_hash['epp']['command']['create']['create'][:postalInfo][:addr][:street] 
    return street if street.is_a? String
    return street.join(',') if street.is_a? Array
    return nil
  end

  def ident_type
    result = params[:frame].slice(/(?<=\<ns2:ident type=)(.*)(?=<)/)

    return nil unless result

    Contact::IDENT_TYPES.any? { |type| return type if result.include?(type) }
    return nil
  end

end
