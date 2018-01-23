module Concerns::Contact::Transferable
  extend ActiveSupport::Concern

  def transfer(new_registrar)
    new_contact = self.dup
    new_contact.registrar = new_registrar
    new_contact.generate_code
    new_contact.original = self
    new_contact.remove_address unless self.class.address_processing?
    new_contact.save!
    new_contact
  end
end
