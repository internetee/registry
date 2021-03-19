namespace :email_bounce do
  desc 'Creates a dummy email bounce by email address'
  task :create_test, [:email] => [:environment] do |_t, args|
    bounced_mail = BouncedMailAddress.new
    bounced_mail.email = args[:email]
    bounced_mail.message_id = '010f0174a0c7d348-ea6e2fc1-0854-4073-b71f-5cecf9b0d0b2-000000'
    bounced_mail.bounce_type = 'Permanent'
    bounced_mail.bounce_subtype = 'General'
    bounced_mail.action = 'failed'
    bounced_mail.status = '5.1.1'
    bounced_mail.diagnostic = 'smtp; 550 5.1.1 user unknown'
    bounced_mail.save!
  end
end
