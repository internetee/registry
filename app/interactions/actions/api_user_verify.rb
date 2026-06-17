# frozen_string_literal: true

module Actions
  # Sends an eeID identification request for an API user.
  class ApiUserVerify
    attr_reader :api_user

    def initialize(api_user)
      @api_user = api_user
    end

    def call
      return false unless validate_email!

      create_identification_request
      return false if api_user.errors.any?

      commit
    end

    private

    def validate_email!
      if api_user.email.blank?
        api_user.errors.add(:email, :blank)
        return false
      end

      true
    end

    def create_identification_request
      ident_service = Eeid::IdentificationService.new('priv')
      response = ident_service.create_identification_request(request_payload)
      ApiUserMailer.identification_requested(api_user: api_user, link: response['link']).deliver_now
    rescue Eeid::IdentError => e
      Rails.logger.error e.message
      api_user.errors.add(:base, :verification_error)
    end

    def request_payload
      {
        claims_required: claims_required,
        reference: api_user.uuid
      }
    end

    def claims_required
      if api_user.subject.present?
        [{ type: 'sub', value: api_user.subject }]
      else
        [{ type: 'sub', value: '' }]
      end
    end

    def commit
      api_user.update(
        ident_request_sent_at: Time.zone.now,
        verified_at: nil,
        verification_id: nil,
        verification_pending_at: nil,
        verification_snapshot: {}
      )
    end
  end
end
