class CompanyRegisterStatusJob < ApplicationJob
  queue_as :default

  def perform(days_interval = 14, spam_time_delay=0.3)
    registrants = Registrant.where(ident_type: 'org')
      .where(
        '(company_register_status IS NULL) OR
        (company_register_status = ? AND (checked_company_at IS NULL OR checked_company_at <= ?)) OR
        (company_register_status = ? AND (checked_company_at IS NULL OR checked_company_at <= ?))',
        Contact::REGISTERED, days_interval.days.ago,
        Contact::LIQUIDATED, 1.day.ago
      )

    registrants.find_in_batches(batch_size: 100) do |contacts|

      contacts.each do |contact|

        # avoid spamming company register
        sleep spam_time_delay

        company_status = contact.return_company_status
        contact.company_register_status = company_status
        contact.checked_company_at = Time.zone.now
        contact.save!

        next unless company_status == Contact::BANKRUPT || company_status == Contact::DELETED
        
        contact.domains.each do |domain|
          domain.schedule_force_delete(type: :fast_track, notify_by_email: true, reason: 'invalid_company', email: contact.email)
        end
      end
    end
  end
end
