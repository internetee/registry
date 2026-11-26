module Contact::Transferable
  extend ActiveSupport::Concern

  included do
    validates :auth_info, presence: true
    after_initialize :generate_auth_info, if: -> { new_record? && auth_info.blank? }
  end

  def transfer(new_registrar)
    return identical(new_registrar) if identical(new_registrar)

    new_contact = build_copy(new_registrar)
    new_contact.save(validate: false)
    new_contact
  end

  # Unsaved copy within the same registrar, to be saved by Actions::ContactCreate (which also
  # generates the code). It starts like a freshly created contact, so it gets nothing a plain
  # REPP create could not set: no statuses, no identity verification.
  def copy
    new_contact = build_copy(registrar)
    new_contact.assign_attributes(code: nil, statuses: [], status_notes: {}, upid: nil, up_date: nil,
                                  ident_request_sent_at: nil, verified_at: nil,
                                  verification_id: nil, verification_pending_at: nil,
                                  verification_snapshot: {})
    new_contact
  end

  protected

  def build_copy(new_registrar)
    new_contact = dup
    new_contact.registrar = new_registrar
    new_contact.original = self
    new_contact.code = nil
    new_contact.regenerate_code
    new_contact.regenerate_auth_info
    new_contact.remove_address unless self.class.address_processing?
    new_contact.uuid = nil
    new_contact
  end

  def generate_auth_info
    self.auth_info = SecureRandom.hex(11)
  end

  alias_method :regenerate_auth_info, :generate_auth_info
end
