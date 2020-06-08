class EmailAddressVerification < ApplicationRecord
  RECENTLY_VERIFIED_PERIOD = 1.month

  scope :not_verified_recently, -> {
    where('verified_at IS NULL or verified_at < ?', verification_period)
  }

  scope :verified_recently, -> {
    where('verified_at IS NOT NULL and verified_at >= ?', verification_period)
  }

  def recently_verified?
    verified_at.present? &&
      verified_at > verification_period
  end

  def verification_period
    self.class.verification_period
  end

  def self.verification_period
    Time.zone.now - RECENTLY_VERIFIED_PERIOD
  end

  def verify
    media = success ? :mx : :smtp
    validation_request = Truemail.validate(email, with: media)

    if validation_request.result.success
      update(verified_at: Time.zone.now,
             success: true)
    end

    validation_request.result.success
  end
end
