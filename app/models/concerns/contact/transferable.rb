module Concerns::Contact::Transferable
  extend ActiveSupport::Concern

  included do
    validates :auth_info, presence: true
    after_initialize :generate_auth_info, if: 'new_record? && auth_info.blank?'
  end

  def transfer(new_registrar)
    new_contact = self.dup
    new_contact.registrar = new_registrar
    new_contact.generate_code
    new_contact.original = self
    new_contact.regenerate_auth_info
    new_contact.remove_address unless self.class.address_processing?
    new_contact.save!
    new_contact
  end

  protected

  def generate_auth_info
    self.auth_info = SecureRandom.hex(11)
  end

  alias_method :regenerate_auth_info, :generate_auth_info
end
