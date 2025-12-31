require 'zip'
require 'csv'

class CompanyRegisterStatusJob < ApplicationJob
  PAYMENT_STATEMENT_BUSINESS_REGISTRY_REASON = 'Kustutamiskanne dokumentide hoidjata'

  # Check intervals for different statuses
  CHECK_INTERVAL_REGISTERED = 1.year
  CHECK_INTERVAL_LIQUIDATED_BANKRUPT = 1.month
  CHECK_INTERVAL_DELETED = 1.day

  REGISTRY_STATUSES = {
    Contact::REGISTERED => 'registered',
    Contact::LIQUIDATED => 'liquidated',
    Contact::BANKRUPT => 'bankrupt',
    Contact::DELETED => 'deleted',
    Contact::NOT_FOUND => 'not_found'
  }.freeze

  queue_as :default

  def perform(spam_time_delay = 1, batch_size = 100)
    sampling_registrant_contacts.find_in_batches(batch_size: batch_size) do |contacts|
      contacts_to_check = contacts.reject { |contact| whitelisted_company?(contact) }

      contacts_to_check.each do |contact|
        proceed_company_status(contact, spam_time_delay)
      end
    end
  end

  private

  def proceed_company_status(contact, spam_time_delay)
    # avoid spamming company register
    sleep spam_time_delay

    company_status = contact.return_company_status
    Rails.logger.info "Checking contact with id #{contact.id} and its ident: #{contact.ident}. His status from business registry is #{company_status}"

    if company_status.blank?
      handle_missing_company(contact)
      return
    end

    handle_company_statuses(contact, company_status)
    update_validation_company_status(contact: contact, status: company_status)
  rescue CompanyRegister::SOAPFaultError => e
    Rails.logger.error("SOAPFaultError for contact #{contact.id} (#{contact.ident}): #{e.message}. Skipping contact.")
  end


  def handle_missing_company(contact)
    Rails.logger.info("Contact #{contact.id} (#{contact.ident}) not found in business registry. Scheduling force delete.")
    schedule_force_delete(contact, nil, nil)
    update_validation_company_status(contact: contact, status: Contact::NOT_FOUND)
  end

  def handle_company_statuses(contact, company_status)
    case company_status
    when Contact::REGISTERED
      lift_force_delete(contact) if check_for_force_delete(contact)
    when Contact::LIQUIDATED
      send_email_for_liquidation(contact)
    when Contact::BANKRUPT
      # Bankrupt companies are tracked but no action needed
      Rails.logger.info("Contact #{contact.id} is bankrupt. No action required.")
    when Contact::DELETED
      delete_process(contact, company_status)
    end
  end

  def send_email_for_liquidation(contact)
    return if contact.company_register_status == Contact::LIQUIDATED

    Rails.logger.info("Sending email for liquidation for contact #{contact.id}")
    ContactInformMailer.company_liquidation(contact: contact).deliver_now
  end

  def sampling_registrant_contacts
    Contact.joins(:registrant_domains)
           .where(ident_type: 'org', ident_country_code: 'EE')
           .where(sampling_conditions)
           .distinct
  end

  def sampling_conditions
    cutoff_registered = CHECK_INTERVAL_REGISTERED.ago.to_date + 1.day
    cutoff_liquidated_bankrupt = CHECK_INTERVAL_LIQUIDATED_BANKRUPT.ago.to_date + 1.day
    cutoff_deleted = CHECK_INTERVAL_DELETED.ago.to_date + 1.day

    <<-SQL.squish
      (company_register_status IS NULL OR checked_company_at IS NULL)
      OR (company_register_status = '#{Contact::REGISTERED}' AND checked_company_at < '#{cutoff_registered}')
      OR (company_register_status IN ('#{Contact::LIQUIDATED}', '#{Contact::BANKRUPT}') AND checked_company_at < '#{cutoff_liquidated_bankrupt}')
      OR (company_register_status = '#{Contact::DELETED}' AND checked_company_at < '#{cutoff_deleted}')
    SQL
  end

  def update_validation_company_status(contact:, status:)
    contact.update(company_register_status: status, checked_company_at: Date.current)
  end

  def schedule_force_delete(contact, company_status, kandeliik_tekstina)
    contact.registrant_domains.each do |domain|
      next if domain.force_delete_scheduled?

      domain.schedule_force_delete(
        type: :fast_track,
        notify_by_email: true,
        reason: 'invalid_company',
        email: contact.email,
        notes: company_status_notes(company_status) + "#{" + #{kandeliik_tekstina}" if kandeliik_tekstina.present?}"
      )
    end
  end

  def check_for_force_delete(contact)
    contact.registrant_domains.any? do |domain|
      notes = domain.status_notes[DomainStatus::FORCE_DELETE]
      notes_check = notes && notes.include?("Company no: #{contact.ident}")
      
      if !notes_check && domain.force_delete_data.present?
        domain.template_name == 'invalid_company'
      else
        notes_check
      end
    end
  end

  def lift_force_delete(contact)
    Rails.logger.info("Lifting force delete for contact #{contact.id}")
    contact.registrant_domains.each do |domain|
      next unless domain.force_delete_scheduled?

      domain.cancel_force_delete
    end
  end

  def delete_process(contact, company_status)
    Rails.logger.info("Processing company details for contact #{contact.id} with ident: #{contact.ident} (#{contact.ident.class})")
    company_details_response = contact.return_company_details

    if company_details_response.empty?
      Rails.logger.info("Empty company details response for contact #{contact.id}")
      schedule_force_delete(contact, company_status, nil)

      return
    end

    kandeliik_tekstina = extract_kandeliik_tekstina(company_details_response)
    Rails.logger.info("Kandeliik tekstina for contact #{contact.id}: #{kandeliik_tekstina}")

    if kandeliik_tekstina == PAYMENT_STATEMENT_BUSINESS_REGISTRY_REASON
      soft_delete_company(contact, company_status, kandeliik_tekstina)
    else
      schedule_force_delete(contact, company_status, kandeliik_tekstina)
    end
  rescue CompanyRegister::SOAPFaultError => e
    Rails.logger.error("Error getting company details for #{contact.ident}: #{e.message}")
  end

  private

  def extract_kandeliik_tekstina(company_details_response)
    company_details_response.first.kandeliik.last.last.kandeliik_tekstina
  end

  def soft_delete_company(contact, company_status, kandeliik_tekstina)
    contact.registrant_domains.reject { |domain| domain.force_delete_scheduled? }.each do |domain|
      next if domain.force_delete_scheduled?
      
      domain.schedule_force_delete(
        type: :soft,
        notify_by_email: true,
        reason: 'invalid_company',
        email: contact.email,
        notes: company_status_notes(company_status) + "#{" + #{kandeliik_tekstina}" if kandeliik_tekstina.present?}"
      )
    end

    puts "Soft delete process initiated for company: #{contact.name} with ID: #{contact.id}"
  end

  def whitelisted_companies
    @whitelisted_companies ||= begin
      raw_list = ENV['whitelist_companies'] || '[]'
      JSON.parse(raw_list)
    rescue JSON::ParserError
      []
    end
  end
  
  def whitelisted_company?(contact)
    whitelisted_companies.include?(contact.ident)
  end

  def company_status_notes(company_status)
    if company_status.nil?
      'Contact not found in EE business registry'
    else
      "Contact has status #{REGISTRY_STATUSES.fetch(company_status, company_status)}"
    end
  end
end
