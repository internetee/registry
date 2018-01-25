module Concerns::Contact::Transferable
  extend ActiveSupport::Concern

  included do
    after_initialize :generate_auth_info, if: :new_record?
  end

  def transfer(new_registrar)
    new_contact = self.dup
    new_contact.registrar = new_registrar
    new_contact.generate_code
    new_contact.original = self
    new_contact.remove_address unless self.class.address_processing?
    new_contact.save!
    new_contact
  end

  def generate_auth_info
    return if @generate_auth_info_disabled
    return if auth_info.present?
    self.auth_info = SecureRandom.hex(11)
  end
end
