module Concerns::Domain::Transferable
  extend ActiveSupport::Concern

  included do
    after_initialize :generate_transfer_code, if: :generate_transfer_code?
  end

  def non_transferable?
    !transferable?
  end

  def transfer(new_registrar)
    self.registrar = new_registrar
    regenerate_transfer_code

    transaction do
      transfer_contacts(new_registrar)
      save!
    end
  end

  private

  def transferable?
    (statuses & [
      DomainStatus::PENDING_DELETE_CONFIRMATION,
      DomainStatus::PENDING_CREATE,
      DomainStatus::PENDING_UPDATE,
      DomainStatus::PENDING_DELETE,
      DomainStatus::PENDING_RENEW,
      DomainStatus::PENDING_TRANSFER,
      DomainStatus::FORCE_DELETE,
      DomainStatus::SERVER_TRANSFER_PROHIBITED,
      DomainStatus::CLIENT_TRANSFER_PROHIBITED
    ]).empty?
  end

  def generate_transfer_code?
    new_record? && transfer_code.blank?
  end

  def generate_transfer_code
    self.transfer_code = SecureRandom.hex
  end

  alias_method :regenerate_transfer_code, :generate_transfer_code

  def transfer_contacts(new_registrar)
    transfer_registrant(new_registrar)
    transfer_domain_contacts(new_registrar)
  end

  def transfer_registrant(new_registrar)
    return if registrant.registrar == new_registrar
    self.registrant = registrant.transfer(new_registrar).becomes(Registrant)
  end

  def transfer_domain_contacts(new_registrar)
    copied_ids = []
    contacts.each do |contact|
      next if copied_ids.include?(contact.id) || contact.registrar == new_registrar

      if registrant_id_was == contact.id # registrant was copied previously, do not copy it again
        oc = OpenStruct.new(id: registrant_id)
      else
        oc = contact.transfer(new_registrar)
      end

      domain_contacts.where(contact_id: contact.id).update_all({ contact_id: oc.id }) # n+1 workaround
      copied_ids << contact.id
    end
  end
end
