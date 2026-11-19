# frozen_string_literal: true

module Actions
  # Registrar manually approves a pending ApiUser identification.
  class ApiUserApproveVerification
    SUB_PATTERN = /\A([A-Z]{2})([0-9A-Za-z]+)\z/

    attr_reader :api_user, :subject, :failure_reason

    def initialize(api_user, subject: nil)
      @api_user = api_user
      @subject = subject.to_s.strip.presence
    end

    def call
      return fail_with(:not_pending_verification) unless api_user.verification_pending_at.present?

      snapshot = (api_user.verification_snapshot || {}).with_indifferent_access
      # Pending snapshot comes from eeID result (OIDC +sub+).
      @subject ||= snapshot[:sub].to_s.strip.presence
      return fail_with(:missing_subject) if subject.blank?

      conflicting_user = find_conflicting_user
      if conflicting_user
        return fail_with(:subject_taken_by_user, subject: subject, username: conflicting_user.username)
      end

      approve!
      true
    rescue ActiveRecord::RecordInvalid => e
      reason = e.record.errors.full_messages.join(', ')
      # The transaction rolled back; drop the in-memory subject and timestamps too.
      api_user.reload
      api_user.errors.clear
      fail_with(:update_failed, reason: reason)
    end

    def failure_message
      api_user.errors.full_messages.join(', ')
    end

    private

    def approve!
      country_code = country_code_from_subject(subject)
      subject_attrs = { subject: subject }
      subject_attrs[:country_code] = country_code if country_code.present?

      ApiUser.transaction do
        # Persist subject first to avoid subject-change callback clearing
        # the verification state set during registrar approval.
        api_user.update_columns(subject_attrs.merge(updated_at: Time.zone.now))
        api_user.update!(
          verified_at: Time.zone.now,
          verification_pending_at: nil
        )
      end
    end

    def fail_with(reason, **options)
      api_user.errors.add(:base, reason, **options)
      @failure_reason = reason
      log_failure
      false
    end

    def log_failure
      Rails.logger.warn(
        '[ApiUserVerification] Manual approval failed: ' \
        "api_user_id=#{api_user.id} username=#{api_user.username} " \
        "registrar=#{api_user.registrar&.code} identity_code=#{api_user.identity_code.presence || '-'} " \
        "subject=#{subject || '-'} reason=#{failure_reason} message=#{failure_message.inspect}"
      )
    end

    def country_code_from_subject(subject)
      match = subject.match(SUB_PATTERN)
      match&.[](1)
    end

    def find_conflicting_user
      ApiUser.where(registrar_id: api_user.registrar_id, subject: subject)
             .where.not(id: api_user.id)
             .first
    end
  end
end
