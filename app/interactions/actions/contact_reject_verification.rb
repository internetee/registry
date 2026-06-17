# frozen_string_literal: true

module Actions
  # Clears pending Contact identification after registrar rejection.
  class ContactRejectVerification
    attr_reader :contact

    def initialize(contact)
      @contact = contact
    end

    def call
      unless contact.verification_pending_at.present?
        contact.errors.add(:base, :not_pending_verification)
        return false
      end

      contact.update!(
        ident_request_sent_at: nil,
        verification_pending_at: nil,
        verification_id: nil,
        verification_snapshot: {}
      )
      true
    end
  end
end
