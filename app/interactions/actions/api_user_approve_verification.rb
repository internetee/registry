# frozen_string_literal: true

module Actions
  # Registrar manually approves a pending ApiUser identification.
  class ApiUserApproveVerification
    SUB_PATTERN = /\A([A-Z]{2})([0-9A-Za-z]+)\z/

    attr_reader :api_user

    def initialize(api_user, subject: nil)
      @api_user = api_user
      @subject = subject.to_s.strip.presence
    end

    def call
      unless api_user.verification_pending_at.present?
        api_user.errors.add(:base, :not_pending_verification)
        return false
      end

      snapshot = (api_user.verification_snapshot || {}).with_indifferent_access
      # Pending snapshot comes from eeID result (OIDC +sub+).
      subject = @subject || snapshot[:sub].to_s.strip.presence

      if subject.blank?
        api_user.errors.add(:base, :missing_subject)
        return false
      end

      if subject_conflict?(subject)
        api_user.errors.add(:subject, :taken)
        return false
      end

      attrs = {
        verified_at: Time.zone.now,
        verification_pending_at: nil,
        subject: subject
      }

      country_code = country_code_from_subject(subject)
      attrs[:country_code] = country_code if country_code.present?

      api_user.update!(attrs)
      true
    end

    private

    def country_code_from_subject(subject)
      match = subject.match(SUB_PATTERN)
      match&.[](1)
    end

    def subject_conflict?(subject)
      ApiUser.where(registrar_id: api_user.registrar_id, subject: subject)
             .where.not(id: api_user.id)
             .exists?
    end
  end
end
