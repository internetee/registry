class CompanyRegisterStatusForSingleDomainJob < ApplicationJob
  REGISTRY_STATUSES = {
    Contact::REGISTERED => 'registered',
    Contact::LIQUIDATED => 'liquidated',
    Contact::BANKRUPT => 'bankrupt',
    Contact::DELETED => 'deleted'
  }.freeze

  queue_as :default

  def perform(domain_name)
    puts "=" * 60
    puts "Checking domain: #{domain_name}"
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

    unless registrant.ident_type == 'org' && registrant.ident_country_code == 'EE'
      puts "SKIP: Not an Estonian organization (ident_type=#{registrant.ident_type}, country=#{registrant.ident_country_code})"
      return
    end

    puts "BUSINESS REGISTRY CHECK:"
    puts "  Querying registry for ident: #{registrant.ident}"

    company_status = registrant.return_company_status
    puts "  Raw status from registry: #{company_status.inspect}"
    puts "  Human status: #{REGISTRY_STATUSES.fetch(company_status, 'NOT_FOUND')}"
    puts "-" * 60

    puts "COMPANY DETAILS (for deletion reason):"
    company_details = registrant.return_company_details

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

    puts "-" * 60
    puts "SUMMARY:"
    puts "  Domain: #{domain_name}"
    puts "  Registrant: #{registrant.name} (#{registrant.ident})"
    puts "  Registry status: #{REGISTRY_STATUSES.fetch(company_status, 'NOT_FOUND')} (#{company_status.inspect})"
    puts "  Force delete scheduled: #{domain.force_delete_scheduled?}"

    if domain.force_delete_scheduled?
      puts "  Force delete type: #{domain.template_name}"
      puts "  Force delete data: #{domain.force_delete_data}"
    end

    puts "=" * 60
  end
end
