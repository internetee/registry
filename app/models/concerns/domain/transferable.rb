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

    transfer_contacts(new_registrar)
  end

  private

  def generate_transfer_code
    self.transfer_code = SecureRandom.hex
  end

  def transfer_contacts(new_registrar)
    transfer_registrant(new_registrar)
    transfer_domain_contacts(new_registrar)
  end

  def transfer_registrant(new_registrar)
    return if registrant.registrar == new_registrar
    self.registrant = registrant.transfer(new_registrar)
  end

  def transfer_domain_contacts(new_registrar)
    copied_ids = []
    contacts.each do |c|
      next if copied_ids.include?(c.id) || c.registrar == new_registrar

      if registrant_id_was == c.id # registrant was copied previously, do not copy it again
        oc = OpenStruct.new(id: registrant_id)
      else
        oc = c.transfer(new_registrar)
      end

      domain_contacts.where(contact_id: c.id).update_all({ contact_id: oc.id }) # n+1 workaround
      copied_ids << c.id
    end
  end

  alias_method :regenerate_transfer_code, :generate_transfer_code
end
