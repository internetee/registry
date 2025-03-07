class OrgRegistrantPhoneCheckerJob < ApplicationJob
  queue_as :default
  
  include Retryable

  # Constants for API error types
  API_EXCEPTIONS = [
    HTTPClient::KeepAliveDisconnected,
    Net::OpenTimeout,
    Timeout::Error,
    Savon::HTTPError,
    Savon::SOAPFault,
    Wasabi::Resolver::HTTPError
  ].freeze

  CACHE_EXPIRES_IN = 1.day

  def perform(type: 'bulk', registrant_user_code: nil, spam_delay: 1)
    case type
    when 'bulk'
      execute_bulk_checker(spam_delay)
    when 'single'
      execute_single_checker(registrant_user_code)
    else
      raise "Invalid type: #{type}. Allowed types: 'bulk', 'single'"
    end
  end

  def execute_bulk_checker(spam_delay)
    log('Bulk checker started')

    Contact.where(ident_type: 'org', ident_country_code: 'EE').joins(:registrant_domains).each do |registrant_user|
      is_phone_number_matching = check_the_registrant_phone_number(registrant_user)
      call_disclosure_action(is_phone_number_matching, registrant_user)
      sleep(spam_delay)
    end

    log('Bulk checker finished')
  end

  def execute_single_checker(registrant_user_code)
    registrant_user = Contact.where(ident_type: 'org', ident_country_code: 'EE')
                             .joins(:registrant_domains)
                             .find_by(code: registrant_user_code)
    return if registrant_user.nil?

    is_phone_number_matching = check_the_registrant_phone_number(registrant_user)
    call_disclosure_action(is_phone_number_matching, registrant_user)
  end

  private

  def call_disclosure_action(is_phone_number_matching, contact)
    if is_phone_number_matching
      disclose_phone_number(contact)
      log("Phone number disclosed for registrant user #{contact.code}. Phone number: #{contact.phone}")
    elsif contact.disclosed_attributes.include?('phone')
      log("Removing phone number from disclosed attributes for registrant user #{contact.code}. Phone number: #{contact.phone}")
      contact.disclosed_attributes.delete('phone')
      contact.save!
    else
      log("Phone number not disclosed for registrant user #{contact.code}. Phone number: #{contact.phone}")
    end
  end

  def log(message)
    Rails.logger.info(message)
  end

  def disclose_phone_number(contact)
    contact.disclosed_attributes << 'phone'
    contact.save!
  end

  def company_register
    @company_register ||= CompanyRegister::Client.new
  end

  def check_the_registrant_phone_number(registrant_user)
    phone_numbers = fetch_phone_number_from_company_register(registrant_user.ident)
    phone_numbers.any? do |phone_number|
      format_phone_number(phone_number) == format_phone_number(registrant_user.phone)
    end
  end

  def format_phone_number(phone_number)
    phone_number.gsub(/\D/, '')
  end

  def fetch_phone_number_from_company_register(company_code)
    cache_key = "company_register:#{company_code}:phone_numbers"
    
    return fetch_from_company_register(company_code) if Rails.env.test? && ENV['SKIP_COMPANY_REGISTER_CACHE']
    
    Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRES_IN) do
      fetch_from_company_register(company_code)
    end
  end

  def fetch_from_company_register(company_code)
    with_retry(
      exceptions: API_EXCEPTIONS,
      logger: Rails.logger,
      fallback: -> { log("Failed to get data for company #{company_code}, returning empty array"); [] }
    ) do
      data = company_register.company_details(registration_number: company_code.to_s)
      log("Successfully retrieved data for company #{company_code}")
      data[0].phone_numbers
    end
  end
end
