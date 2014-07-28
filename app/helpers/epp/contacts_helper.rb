module Epp::ContactsHelper
  def create_contact
    ph = params_hash['epp']['command']['create']['create']

    ph[:ident] ? @contact = Contact.where(ident: ph[:ident]).first_or_initialize : @contact = Contact.new  
    if @contact.new_record?
      @contact.assign_attributes(
        code: ph[:id],
        phone: ph[:voice],
        ident: ph[:ident],
        email: ph[:email]
      )
    end   
    @contact.name = ph[:postalInfo][:name]

    @contact.addresses << Address.new(
      country_id: Country.find_by(iso: ph[:postalInfo][:cc]),
      street: ph[:postalInfo][:street],
      zip: ph[:postalInfo][:pc]
    )

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
      @code = '2303'
      @msg = "Object does not exist"
      render '/epp/error'
    rescue
      @code = '2400'
      @msg = "Command failed"
      render '/epp/error'
    end
  end

  def check_contact
    ph = params_hash['epp']['command']['check']['check']
    @contacts = Contact.check_availability( ph[:id] )

    if @contacts.any?
      render '/epp/contacts/check'
    else
      @code = '2303'
      @msg = "Object does not exist"
      render 'epp/error'
    end
  end
end
