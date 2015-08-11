TEST_EMAILS = 
  if Rails.env.test?
    %w(
      test@example.com
      test@example.org
      old@example.org
      new@example.org
      old@example.com
      new@example.com
    )
  else
    ENV['whitelist_emails_for_staging'].split(',').map(&:strip)
  end
