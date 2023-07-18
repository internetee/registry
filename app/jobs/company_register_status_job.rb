class CompanyRegisterStatusJob < ApplicationJob
  queue_as :default

  def perform(days_interval = 14, spam_time_delay = 0.2, batch_size = 100, force_delete = false)
    sampling_registrant_contact(days_interval).find_in_batches(batch_size: batch_size) do |contacts|
      contacts.each do |contact|
        # avoid spamming company register
        sleep spam_time_delay

        company_status = contact.return_company_status
        contact.update!(company_register_status: company_status, checked_company_at: Time.zone.now)

        ContactInformMailer.company_liquidation(contact: contact).deliver_now if company_status == Contact::LIQUIDATED

        next unless [Contact::BANKRUPT, Contact::DELETED, nil].include? company_status

        if force_delete
          schedule_force_delete(contact)
        else
          generate_alert_list(contact, company_status)
        end
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

  def generate_alert_list(contact, company_status)
    File.open(Rails.root.join('contact_companies_alert_list.txt'), 'a') do |f|
      f.puts "#{contact.name} - #{contact.ident} - #{company_status}"
    end
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
