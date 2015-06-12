class ContactMailer < ApplicationMailer
  # rubocop: disable Metrics/CyclomaticComplexity
  def email_updated(contact)
    unless Rails.env.production?
      return unless TEST_EMAILS.include?(contact.email) || TEST_EMAILS.include?(contact.email_was)
    end

    # turn on delivery on specific request only, thus rake tasks does not deliver anything
    return if contact.deliver_emails != true

    @contact = contact

    emails = []
    emails << [@contact.email, @contact.email_was] if @contact.registrant_domains.present?
    emails << @contact.domains.map(&:email) if @contact.domains.present?
    emails = emails.uniq
    
    emails.each do |email|
      mail(to: email, subject: "#{I18n.t(:contact_email_update_subject)} [#{@contact.code}]")
    end
  end
  # rubocop: enable Metrics/CyclomaticComplexity
end
