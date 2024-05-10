require 'zip'

class CompanyRegisterStatusJob < ApplicationJob
  queue_as :default

  def perform(days_interval = 14, spam_time_delay = 1, batch_size = 100)
    sampling_registrant_contact(days_interval).find_in_batches(batch_size: batch_size) do |contacts|
      contacts.each { |contact| proceed_company_status(contact, spam_time_delay) }
    end
  end

  private

  def proceed_company_status(contact, spam_time_delay)
    # avoid spamming company register
    sleep spam_time_delay

    company_status = contact.return_company_status
    contact.update!(company_register_status: company_status, checked_company_at: Time.zone.now)

    case company_status
    when Contact::REGISTERED
      lift_force_delete(contact) if check_for_force_delete(contact)
    when Contact::LIQUIDATED
      ContactInformMailer.company_liquidation(contact: contact).deliver_now
    else
      # Here is case when company is not found in the register or it is deleted (Contact::DELETED status) or bankrupt (Contact::BANKRUPT status)
      schedule_force_delete(contact)
    end

    status = company_status.blank? ? Contact::DELETED : company_status
    puts status
    update_validation_company_status(contact:contact , status: status)
  end

  def sampling_registrant_contact(days_interval)
    Registrant.where(ident_type: 'org', ident_country_code: 'EE').where(
      "(company_register_status IS NULL OR checked_company_at IS NULL) OR
      (company_register_status = ? AND checked_company_at < ?) OR
      company_register_status IN (?)",
      Contact::REGISTERED, days_interval.days.ago, [Contact::LIQUIDATED, Contact::BANKRUPT, Contact::DELETED]
    )

  end

  def update_validation_company_status(contact:, status:)
    contact.update(company_register_status: status, checked_company_at: Time.zone.now)
  end
  
  def schedule_force_delete(contact)
    contact.domains.each do |domain|
      next if domain.schedule_force_delete?

      domain.schedule_force_delete(
        type: :fast_track,
        notify_by_email: true,
        reason: 'invalid_company',
        email: contact.email
      )
    end
  end

  def check_for_force_delete(contact)
    contact.domains.any? do |domain| 
      domain.schedule_force_delete? && domain.status_notes[DomainStatus::FORCE_DELETE].include?("Company no: #{contact.ident}")
    end
  end

  def lift_force_delete(contact)
    contact.domains.each do |domain|
      domain.lift_force_delete
    end
  end
end
