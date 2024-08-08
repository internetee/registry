class SmtpEmailCheckJob < ApplicationJob
  def perform
    contact_emails = Contact.all.pluck(:email)
    
    contact_emails.each do |email|
      result = GreylistChecker.new(email).check

      puts '---------'
      puts result
      puts '---------'
    end
  end
end