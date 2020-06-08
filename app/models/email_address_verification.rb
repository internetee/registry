class EmailAddressVerification < ApplicationRecord

  RECENTLY_VERIFIED_PERIOD = 1.month

  def recently_verified?
    verified_at.present? &&
      verified_at > Time.zone.now - RECENTLY_VERIFIED_PERIOD
  end

  def verify
    validation_request = Truemail.validate(email)

    if validation_request.result.success
      update(verified_at: Time.zone.now,
             success: true)
    end

    validation_request.result.success
  end
end
