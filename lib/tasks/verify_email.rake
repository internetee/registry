namespace :verify_email do
  desc 'Stars verifying email jobs for all the domain'
  task all_domains: :environment do
    verifications_by_domain = EmailAddressVerification.not_verified_recently.group_by(&:domain)
    verifications_by_domain.each do |_domain, verifications|
      ver = verifications.sample # Verify random email to not to clog the SMTP servers
      VerifyEmailsJob.perform_later(ver.id)
      next
    end
  end

  # Need to be run like 'bundle exec rake verify_email:domain['gmail.com']'
  # In zsh syntax will be 'bundle exec rake verify_email:domain\['gmail.com'\]'
  # Default 'bundle exec rake verify_email:domain' wil use 'internet.ee' domain
  desc 'Stars verifying email jobs for domain stated in argument'
  task :domain, [:domain_name] => [:environment] do |_task, args|
    args.with_defaults(domain_name: 'internet.ee')

    verifications_by_domain = EmailAddressVerification.not_verified_recently
                                                      .by_domain(args[:domain_name])
    verifications_by_domain.map { |ver| VerifyEmailsJob.perform_later(ver.id) }
  end
end
