namespace :verify_email do
  desc 'Stars verifying email jobs'
  task all_domains: :environment do
    verifications_by_domain = EmailAddressVerification.not_verified_recently.group_by(&:domain)
    verifications_by_domain.each do |_domain, verifications|
      ver = verifications.sample # Verify random email to not to clog the SMTP servers
      VerifyEmailsJob.enqueue(ver.id)
      next
    end
  end
end
