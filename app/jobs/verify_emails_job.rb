class VerifyEmailsJob < Que::Job
  def run(verification_id)
    email_address_verification = run_condition(EmailAddressVerification.find(verification_id))

    return if email_address_verification.recently_verified?

    ActiveRecord::Base.transaction do
      email_address_verification.verify
      log_success(email_address_verification)
      destroy
    end
  rescue StandardError => e
    log_error(verification: email_address_verification, error: e)
    raise e
  end

  private

  def run_condition(email_address_verification)
    destroy unless email_address_verification
    destroy if email_address_verification.recently_verified?

    email_address_verification
  end

  def logger
    @logger ||= Logger.new(Rails.root.join('log', 'email_verification.log'))
  end

  def log_success(verification)
    email = verification.try(:email) || verification
    message = "Email address #{email} verification done"
    logger.info message
  end

  def log_error(verification:, error:)
    email = verification.try(:email) || verification
    message = <<~TEXT.squish
      There was an error verifying email #{email}.
      The error message was the following: #{error}
      This job will retry.
    TEXT
    logger.error message
  end
end
