# frozen_string_literal: true

module Actions
  # Clears pending ApiUser identification after registrar rejection.
  class ApiUserRejectVerification
    attr_reader :api_user

    def initialize(api_user)
      @api_user = api_user
    end

    def call
      unless api_user.verification_pending_at.present?
        api_user.errors.add(:base, :not_pending_verification)
        return false
      end

      api_user.update!(
        verification_pending_at: nil,
        verification_id: nil,
        verification_snapshot: {}
      )
      true
    end
  end
end
