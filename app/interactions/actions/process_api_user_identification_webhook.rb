# frozen_string_literal: true

module Actions
  # Applies eeID identification results to an ApiUser (auto-verify or pending review).
  class ProcessApiUserIdentificationWebhook
    SUB_PATTERN = /\A([A-Z]{2})([0-9A-Za-z]+)\z/

    attr_reader :api_user, :outcome

    def initialize(api_user, identification_request_id:, result:)
      @api_user = api_user
      @identification_request_id = identification_request_id
      @result = (result || {}).with_indifferent_access
    end

    def call
      unless api_user.ident_request_sent_at.present?
        Rails.logger.error("ApiUser verification ignored: ident not requested for user #{api_user.id}")
        @outcome = :ignored
        return false
      end

      if auto_verifiable?
        apply_auto_verification!
        @outcome = :auto_verified
      else
        apply_pending_review!(pending_reason)
        @outcome = :pending_review
      end

      true
    end

    def pending_reason
      @pending_reason ||= compute_pending_reason
    end

    private

    def compute_pending_reason
      subject = result_subject
      return :missing_subject if subject.blank?

      return :subject_conflict if subject_conflict?(subject)
      return :subject_mismatch if pre_set_subject_mismatch?(subject)

      nil
    end

    def auto_verifiable?
      pending_reason.nil?
    end

    # eeID identification result uses OIDC userinfo; login id is in +sub+, not +subject+.
    def result_subject
      @result[:sub].to_s.strip.presence
    end

    def subject_conflict?(subject)
      ApiUser.where(registrar_id: api_user.registrar_id, subject: subject)
             .where.not(id: api_user.id)
             .exists?
    end

    def pre_set_subject_mismatch?(subject)
      expected = api_user.subject.presence || subject_from_identity_code
      expected.present? && expected != subject
    end

    def subject_from_identity_code
      return nil if api_user.identity_code.blank?

      country = api_user.country_code.presence || 'EE'
      "#{country}#{api_user.identity_code}"
    end

    def apply_auto_verification!
      subject = result_subject
      attrs = {
        subject: subject,
        verified_at: Time.zone.now,
        verification_id: @identification_request_id,
        verification_pending_at: nil,
        verification_snapshot: {}
      }

      country_code = country_code_from_subject(subject)
      attrs[:country_code] = country_code if country_code.present?

      api_user.update!(attrs)
      Rails.logger.info("ApiUser verified (auto): #{api_user.id}")
    end

    def country_code_from_subject(subject)
      match = subject.match(SUB_PATTERN)
      match&.[](1)
    end

    def apply_pending_review!(reason)
      api_user.update!(
        verification_id: @identification_request_id,
        verification_pending_at: Time.zone.now,
        verification_snapshot: verification_snapshot,
        verified_at: nil
      )
      Rails.logger.info("ApiUser verification pending (#{reason}): #{api_user.id}")
    end

    def verification_snapshot
      @result.slice(:sub, :given_name, :family_name, :name, :date_of_birth, :birthdate, :country,
                    :authentication_type).compact
    end
  end
end
