class EmailAddressVerification < ApplicationRecord
  RECENTLY_VERIFIED_PERIOD = 1.month

  scope :not_verified_recently, lambda {
    where('verified_at IS NULL or verified_at < ?', verification_period)
  }

  scope :verified_recently, lambda {
    where('verified_at IS NOT NULL and verified_at >= ?', verification_period).where(success: true)
  }

  scope :verification_failed, lambda {
    where.not(verified_at: nil).where(success: false)
  }

  scope :by_domain, ->(domain_name) { where(domain: domain_name) }

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

  def not_verified?
    verified_at.blank? && !success
  end

  def failed?
    verified_at.present? && !success
  end

  def verified?
    success
  end

  def verify
    validation_request = Truemail.validate(email)

    if validation_request.result.success
      update(verified_at: Time.zone.now,
             success: true)
    else
      update(verified_at: Time.zone.now,
             success: false)
    end

    validation_request.result
  end
end
