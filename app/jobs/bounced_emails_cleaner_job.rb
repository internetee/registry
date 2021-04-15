class BouncedEmailsCleanerJob < ApplicationJob
  queue_as :default

  def perform
    BouncedMailAddress.find_each do |bounce|
        count = Contact.where(email: bounce.email).count
        bounce.destroy if count == 0
      end
  end
end