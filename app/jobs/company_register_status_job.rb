require 'zip'

class CompanyRegisterStatusJob < ApplicationJob
# TODO:
# 1) whitelist for some organizations

# Done
# 2) if company os K or N or missing, then:
# 2.1) get info about this ocmpanuy if it exists and if it hasn't financial statements, then soft delete
# 2.2) other cases force delete

# Done
# 4) if org with fd is existed again or org with sd pay his invoices, then we remove fd and sd

# 5) scan should work everyday for all organizaion states (who has fd and who hasn't)
# 

  PAYMENT_STATEMENT_BUSINESS_REGISTRY_REASON = 'Kustutamiskanne dokumentide hoidjata'

  queue_as :default

  def perform(days_interval = 14, spam_time_delay = 1, batch_size = 100)
    sampling_registrant_contact(days_interval).find_in_batches(batch_size: batch_size) do |contacts|
      contacts.reject { |contact| whitelisted_company?(contact) }.each { |contact| proceed_company_status(contact, spam_time_delay) }
    end
  end

  private

  def proceed_company_status(contact, spam_time_delay)
    # avoid spamming company register
    sleep spam_time_delay

    company_status = contact.return_company_status
    contact.update!(company_register_status: company_status, checked_company_at: Time.zone.now)

    puts "company id #{contact.id} status: #{company_status}"

    case company_status
    when Contact::REGISTERED
      lift_force_delete(contact) if check_for_force_delete(contact)
    when Contact::LIQUIDATED
      ContactInformMailer.company_liquidation(contact: contact).deliver_now
    else
      delete_process(contact)
    end

    status = company_status.blank? ? Contact::DELETED : company_status
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
    contact.domains.any? && domain.status_notes[DomainStatus::FORCE_DELETE].include?("Company no: #{contact.ident}") do |domain|
      domain.schedule_force_delete? 
    end
  end

  def lift_force_delete(contact)
    contact.domains.each(&:lift_force_delete)
  end

  def delete_process(contact)
    company_details_response = contact.return_company_details

    if company_details_response.empty?
      schedule_force_delete(contact)
      return
    end

    kandeliik_tekstina = extract_kandeliik_tekstina(company_details_response)
    
    if kandeliik_tekstina == PAYMENT_STATEMENT_BUSINESS_REGISTRY_REASON
      soft_delete_company(contact)
    else
      schedule_force_delete(contact)
    end
  end

  private

  def extract_kandeliik_tekstina(company_details_response)
    company_details_response.first.kandeliik.last.last.kandeliik_tekstina
  end

  def soft_delete_company(contact)
    contact.domains.reject { |domain| domain.force_delete_scheduled? }.each do |domain|
      domain.schedule_force_delete(type: :soft)
    end
    
    puts "Soft delete process initiated for company: #{contact.name} with ID: #{contact.id}"
  end

  def whitelisted_companies
    @whitelisted_companies ||= ENV['whitelist_companies'].split(',')
  end

  def whitelisted_company?(contact)
    whitelisted_companies.include?(contact.ident)
  end
end
