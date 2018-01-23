module Concerns::Domain::Transferable
  extend ActiveSupport::Concern

  included do
    after_initialize :generate_transfer_code, if: :new_record?
  end

  def transfer(new_registrar)
    old_registrar = registrar

    self.registrar = new_registrar
    regenerate_transfer_code

    domain_transfers.create!(
      transfer_requested_at: Time.zone.now,
      transfer_from: old_registrar,
      transfer_to: new_registrar
    )

    transfer_contacts(new_registrar.id)
  end

  private

  def generate_transfer_code
    self.transfer_code = SecureRandom.hex
  end

  def transfer_contacts(registrar_id)
    transfer_registrant(registrar_id)
    transfer_domain_contacts(registrar_id)
  end

  def transfer_registrant(registrar_id)
    return if registrant.registrar_id == registrar_id
    self.registrant_id = copy_and_transfer_contact(registrant_id, registrar_id).id
  end

  def transfer_domain_contacts(registrar_id)
    copied_ids = []
    contacts.each do |c|
      next if copied_ids.include?(c.id) || c.registrar_id == registrar_id

      if registrant_id_was == c.id # registrant was copied previously, do not copy it again
        oc = OpenStruct.new(id: registrant_id)
      else
        oc = copy_and_transfer_contact(c.id, registrar_id)
      end

      domain_contacts.where(contact_id: c.id).update_all({ contact_id: oc.id }) # n+1 workaround
      copied_ids << c.id
    end
  end

  def copy_and_transfer_contact(contact_id, registrar_id)
    c = Contact.find(contact_id) # n+1 workaround
    oc = c.deep_clone
    oc.code = nil
    oc.registrar_id = registrar_id
    oc.original = c
    oc.generate_code
    oc.remove_address unless Contact.address_processing?
    oc.save!(validate: false)
    oc
  end

  alias_method :regenerate_transfer_code, :generate_transfer_code
end
