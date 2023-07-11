class CompanyRegisterStatusJob < ApplicationJob
  queue_as :default

  def perform(days_interval = 14, spam_time_delay = 0.2, batch_size = 100)
    sampling_registrant_contact(days_interval).find_in_batches(batch_size: batch_size) do |contacts|
      contacts.each do |contact|
        # avoid spamming company register
        sleep spam_time_delay

        company_status = contact.return_company_status
        contact.update!(company_register_status: company_status, checked_company_at: Time.zone.now)

        next unless [Contact::BANKRUPT, Contact::DELETED].include? company_status

        schedule_force_delete(contact)
      end
    end
  end

  private

  def sampling_registrant_contact(days_interval)
    Registrant.where(ident_type: 'org')
              .where('(company_register_status IS NULL) OR
                (company_register_status = ? AND (checked_company_at IS NULL OR checked_company_at <= ?)) OR
                (company_register_status = ? AND (checked_company_at IS NULL OR checked_company_at <= ?))',
              Contact::REGISTERED, days_interval.days.ago, Contact::LIQUIDATED, 1.day.ago)
  end

  def schedule_force_delete(contact)
    contact.domains.each do |domain|
      domain.schedule_force_delete(
        type: :fast_track,
        notify_by_email: true,
        reason: 'invalid_company',
        email: contact.email
      )
    end
  end
end
