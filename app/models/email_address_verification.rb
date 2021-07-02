class EmailAddressVerification < ApplicationRecord
  RECENTLY_VERIFIED_PERIOD = 1.month
  # after_save :check_force_delete

  def failed?
    bounce_present? || (verified_at.present? && !success)
  end

  def verified?
    success
  end

  def bounce_present?
    BouncedMailAddress.find_by(email: email).present?
  end

  def check_force_delete
    return unless failed?

    Domains::ForceDeleteEmail::Base.run(email: email)
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
