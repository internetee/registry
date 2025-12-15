class CompanyRegisterStatusForSingleDomainJob < ApplicationJob
  REGISTRY_STATUSES = {
    Contact::REGISTERED => 'registered',
    Contact::LIQUIDATED => 'liquidated',
    Contact::BANKRUPT => 'bankrupt',
    Contact::DELETED => 'deleted'
  }.freeze

  queue_as :default

  # Usage:
  #   CompanyRegisterStatusForSingleDomainJob.perform_now('example.ee')           - by domain
  #   CompanyRegisterStatusForSingleDomainJob.perform_now('12345678', type: :reg) - by registration number
  def perform(identifier, type: :domain)
    puts "=" * 60

    case type.to_sym
    when :reg, :registration_number, :ident
      check_by_registration_number(identifier.to_s)
    else
      check_by_domain(identifier)
    end

    puts "=" * 60
  end

  private

  def check_by_domain(domain_name)
    puts "Checking by DOMAIN: #{domain_name}"
    puts "=" * 60

    domain = Domain.find_by(name: domain_name)
    unless domain
      puts "ERROR: Domain '#{domain_name}' not found"
      return
    end

    puts "Domain ID: #{domain.id}"
    puts "Domain status: #{domain.statuses.join(', ')}"
    puts "-" * 60

    registrant = domain.registrant
    unless registrant
      puts "ERROR: Registrant not found for domain"
      return
    end

    print_registrant_info(registrant)

    unless estonian_org?(registrant)
      puts "SKIP: Not an Estonian organization (ident_type=#{registrant.ident_type}, country=#{registrant.ident_country_code})"
      return
    end

    check_registry(registrant.ident)
    print_domain_summary(domain, registrant)
  end

  def check_by_registration_number(registration_number)
    puts "Checking by REGISTRATION NUMBER: #{registration_number}"
    puts "=" * 60

    # Check if we have contacts with this ident in DB
    contacts = Contact.where(ident: registration_number, ident_type: 'org', ident_country_code: 'EE')
    if contacts.exists?
      puts "Found #{contacts.count} contact(s) in DB with this ident:"
      contacts.each do |c|
        puts "  - #{c.code}: #{c.name} (#{c.email})"
      end
      puts "-" * 60
    else
      puts "No contacts found in DB with this ident (checking registry directly)"
      puts "-" * 60
    end

    check_registry(registration_number)
    print_registration_summary(registration_number, contacts)
  end

  def check_registry(registration_number)
    puts "BUSINESS REGISTRY CHECK:"
    puts "  Querying registry for ident: #{registration_number}"

    # Debug: show configuration
    puts ""
    puts "  CONFIG DEBUG:"
    puts "    Username: #{CompanyRegister.configuration.username.present? ? '***SET***' : 'NOT SET!'}"
    puts "    Password: #{CompanyRegister.configuration.password.present? ? '***SET***' : 'NOT SET!'}"
    puts "    Test mode: #{CompanyRegister.configuration.test_mode}"
    puts "    Cache period: #{CompanyRegister.configuration.cache_period}"
    endpoint = CompanyRegister.configuration.test_mode ? 'https://demo-ariregxmlv6.rik.ee/' : 'https://ariregxmlv6.rik.ee/'
    puts "    Endpoint: #{endpoint}"
    puts ""

    client = CompanyRegister::Client.new

    # Simple data (status)
    puts "  Calling simple_data..."
    simple_data = client.simple_data(registration_number: registration_number)
    if simple_data.blank?
      puts "  Simple data: EMPTY (company not found in registry)"
      @company_status = nil
    else
      @company_status = simple_data.first[:status]
      puts "  Raw status from registry: #{@company_status.inspect}"
      puts "  Human status: #{REGISTRY_STATUSES.fetch(@company_status, 'UNKNOWN')}"
    end
    puts "-" * 60

    # Company details (for deletion reason)
    puts "COMPANY DETAILS (for deletion reason):"
    puts "  Calling company_details..."
    company_details = client.company_details(registration_number: registration_number)

    if company_details.blank?
      puts "  No company details returned (company may not exist in registry)"
    else
      puts "  Raw response class: #{company_details.class}"
      puts "  Response count: #{company_details.size}"

      begin
        kandeliik = company_details.first.kandeliik
        puts "  Kandeliik entries: #{kandeliik.size}"

        kandeliik_tekstina = kandeliik.last.last.kandeliik_tekstina
        puts "  Last kandeliik_tekstina: #{kandeliik_tekstina}"
        puts "  Is PAYMENT_STATEMENT reason: #{kandeliik_tekstina == 'Kustutamiskanne dokumentide hoidjata'}"
      rescue => e
        puts "  Error extracting kandeliik: #{e.message}"
        puts "  Raw company_details: #{company_details.inspect}"
      end
    end
  rescue CompanyRegister::NotAvailableError => e
    puts ""
    puts "  ERROR: Company register not available!"
    puts "  This is usually caused by:"
    puts "    1. Missing/invalid credentials (username/password)"
    puts "    2. Network connectivity issues"
    puts "    3. Registry service is down"
    puts "    4. IP not whitelisted on registry side"
    puts ""
    puts "  Original Savon error was caught and wrapped."
    puts "  To see the actual error, run in rails console:"
    puts "    client = CompanyRegister::Client.new"
    puts "    Savon.client(wsdl: 'https://ariregxmlv6.rik.ee/?wsdl').call(:lihtandmed_v2, message: { keha: { ariregistri_kood: '#{registration_number}' } })"
    puts ""
  rescue => e
    puts "  ERROR: #{e.class} - #{e.message}"
    puts "  Backtrace: #{e.backtrace.first(5).join("\n            ")}"
  end

  def print_registrant_info(registrant)
    puts "REGISTRANT INFO:"
    puts "  Code: #{registrant.code}"
    puts "  Name: #{registrant.name}"
    puts "  Ident: #{registrant.ident}"
    puts "  Ident type: #{registrant.ident_type}"
    puts "  Ident country: #{registrant.ident_country_code}"
    puts "  Email: #{registrant.email}"
    puts "  Current DB status: #{registrant.company_register_status || 'NULL'}"
    puts "  Last checked at: #{registrant.checked_company_at || 'NEVER'}"
    puts "-" * 60
  end

  def print_domain_summary(domain, registrant)
    puts "-" * 60
    puts "SUMMARY:"
    puts "  Domain: #{domain.name}"
    puts "  Registrant: #{registrant.name} (#{registrant.ident})"
    puts "  Registry status: #{REGISTRY_STATUSES.fetch(@company_status, 'NOT_FOUND')} (#{@company_status.inspect})"
    puts "  Force delete scheduled: #{domain.force_delete_scheduled?}"

    if domain.force_delete_scheduled?
      puts "  Force delete type: #{domain.template_name}"
      puts "  Force delete data: #{domain.force_delete_data}"
    end
  end

  def print_registration_summary(registration_number, contacts)
    puts "-" * 60
    puts "SUMMARY:"
    puts "  Registration number: #{registration_number}"
    puts "  Registry status: #{REGISTRY_STATUSES.fetch(@company_status, 'NOT_FOUND')} (#{@company_status.inspect})"
    puts "  Contacts in DB: #{contacts.count}"

    return unless contacts.exists?

    puts "  Domains affected:"
    contacts.each do |contact|
      contact.registrant_domains.each do |domain|
        fd_status = domain.force_delete_scheduled? ? " [FORCE DELETE: #{domain.template_name}]" : ""
        puts "    - #{domain.name}#{fd_status}"
      end
    end
  end

  def estonian_org?(contact)
    contact.ident_type == 'org' && contact.ident_country_code == 'EE'
  end
end
