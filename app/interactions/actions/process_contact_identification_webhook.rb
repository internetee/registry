# frozen_string_literal: true

module Actions
  # Applies eeID identification results to a Contact (auto-verify or pending review).
  class ProcessContactIdentificationWebhook
    attr_reader :contact, :outcome

    def initialize(contact, identification_request_id:, result:)
      @contact = contact
      @identification_request_id = identification_request_id
      @result = (result || {}).with_indifferent_access
    end

    def call
      unless contact.ident_request_sent_at.present?
        Rails.logger.error("Contact verification ignored: ident not requested for contact #{contact.id}")
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
      if contact.ident_type == Contact::BIRTHDAY
        return :missing_claims if birthday_claims_incomplete?
        return :claim_mismatch if birthday_claim_mismatch?
      else
        subject = result_subject
        return :missing_subject if subject.blank?
        return :ident_mismatch if ident_mismatch?(subject)
      end

      nil
    end

    def auto_verifiable?
      pending_reason.nil?
    end

    def result_subject
      @result[:sub].to_s.strip.presence
    end

    def expected_subject
      "#{contact.ident_country_code}#{contact.ident}"
    end

    def ident_mismatch?(subject)
      subject != expected_subject
    end

    def birthday_claims_incomplete?
      birthdate_from_result.blank? || name_from_result.blank? || country_from_result.blank?
    end

    def birthday_claim_mismatch?
      normalize(birthdate_from_result) != normalize(contact.ident) ||
        normalize(name_from_result) != normalize(contact.name) ||
        normalize(country_from_result) != normalize(contact.ident_country_code)
    end

    def birthdate_from_result
      @result[:birthdate].presence || @result[:date_of_birth].presence
    end

    def name_from_result
      @result[:name].presence ||
        [@result[:given_name], @result[:family_name]].compact.join(' ').strip.presence
    end

    def country_from_result
      @result[:country].to_s.strip.upcase.presence
    end

    def normalize(value)
      value.to_s.strip.upcase
    end

    def apply_auto_verification!
      contact.update!(
        verified_at: Time.zone.now,
        verification_id: @identification_request_id,
        verification_pending_at: nil,
        verification_snapshot: {}
      )
      Rails.logger.info("Contact verified (auto): #{contact.id}")
    end

    def apply_pending_review!(reason)
      contact.update!(
        verification_id: @identification_request_id,
        verification_pending_at: Time.zone.now,
        verification_snapshot: verification_snapshot,
        verified_at: nil
      )
      Rails.logger.info("Contact verification pending (#{reason}): #{contact.id}")
    end

    def verification_snapshot
      @result.slice(:sub, :given_name, :family_name, :name, :date_of_birth, :birthdate, :country,
                    :authentication_type).compact
    end
  end
end
