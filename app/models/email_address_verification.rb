class EmailAddressVerification < ApplicationRecord
  belongs_to :email_verifable, polymorphic: true

  RECENTLY_VERIFIED_PERIOD = 1.year.freeze
  SCAN_CYCLES = 3.freeze
  # after_save :check_force_delete


  scope :verification_failed, lambda {
    where.not(verified_at: nil).where(success: false)
  }

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
