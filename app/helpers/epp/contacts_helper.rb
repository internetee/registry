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
end
