# frozen_string_literal: true

# Valid Estonian ID code generator (simplistic)
def generate_ident(sex: 'm', birth_date: '900101')
  # Sex: 1/3/5 for male (1800, 1900, 2000), 2/4/6 for female
  century_sex = sex == 'm' ? '3' : '4' 
  
  # Basic body
  body = "#{century_sex}#{birth_date}001" 
  
  # Checksum calculation
  weights1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 1]
  weights2 = [3, 4, 5, 6, 7, 8, 9, 1, 2, 3]
  
  chars = body.chars.map(&:to_i)
  sum = chars.each_with_index.sum { |c, i| c * weights1[i] }
  mod = sum % 11
  
  if mod == 10
    sum = chars.each_with_index.sum { |c, i| c * weights2[i] }
    mod = sum % 11
    mod = 0 if mod == 10
  end
  
  "#{body}#{mod}"
end

def generate_phone
  "+372.5#{rand(10_000_000..99_999_999)}"
end

def generate_email(first, last)
  safe_first = first.downcase.gsub(/[^a-z0-9]/, '')
  safe_last = last.downcase.gsub(/[^a-z0-9]/, '')
  "#{safe_first}.#{safe_last}+mock@example.com"
end

def generate_random_string(length = 8)
  ('a'..'z').to_a.sample(length).join
end

puts "Starting Mock Data Generation..."

ActiveRecord::Base.transaction do
  # Cleaning up old mock data if necessary (comment out if you want to keep old data)
  # puts "Cleaning up old mock data..."
  # Domain.destroy_all
  # Contact.destroy_all
  # Registrar.where("code LIKE 'MOCK%'").destroy_all
  # ...

  # 1. Ensure Zone exists
  zone_origin = 'ee'
  zone = DNS::Zone.find_or_create_by!(origin: zone_origin) do |z|
    z.ttl = 86400
    z.refresh = 3600
    z.retry = 900
    z.expire = 604800
    z.minimum_ttl = 3600
    z.email = 'hostmaster.ee'
    z.master_nameserver = 'ns1.tld.ee'
  end
  puts "Zone ensured: #{zone.origin}"

  # 2. Ensure Prices exist
  ['create', 'renew'].each do |op|
    Billing::Price.durations.each do |dur_name, dur_val|
      Billing::Price.find_or_create_by!(
        zone: zone, 
        operation_category: op, 
        duration: dur_val
      ) do |p|
        p.price = Money.new(1000, 'EUR') # 10.00 EUR
        p.valid_from = Time.zone.now.beginning_of_year
      end
    end
  end
  puts "Prices ensured for #{zone.origin}"

  # 3. Create Multiple Registrars
  3.times do |reg_i|
    reg_code = "MOCKREG#{reg_i+1}"
    puts "Processing Registrar: #{reg_code}..."

    registrar = Registrar.find_or_create_by!(code: reg_code) do |r|
      r.name = "Mock Registrar #{reg_i+1} Ltd"
      r.reg_no = "1234#{reg_i+1}000"
      r.email = "support@mock#{reg_i+1}.test"
      r.phone = "+372.5555#{reg_i+1}00"
      r.address_street = "Mock St #{reg_i+1}"
      r.address_city = "Tallinn"
      r.address_zip = "10111"
      r.address_country_code = "EE"
      r.accounting_customer_code = "MOCK#{reg_i+1}"
      r.language = "en"
      r.reference_no = Billing::ReferenceNo.generate(owner: r) rescue "123456#{reg_i+1}"
    end
    
    # Ensure account
    registrar.accounts.find_or_create_by!(account_type: Account::CASH, currency: 'EUR')
    puts "  Registrar ensured: #{registrar.name}"

    # 4. Create API User for Registrar
    api_username = "api_#{reg_code.downcase}"
    api_user = ApiUser.find_or_create_by!(username: api_username) do |u|
      u.plain_text_password = "password123"
      u.registrar = registrar
      u.roles = ['epp', 'billing']
      u.active = true
      u.identity_code = generate_ident(sex: 'm', birth_date: "8#{reg_i}0101")
    end
    puts "  API User ensured: #{api_user.username}"

    # 5. Create Contacts (Registrants) for THIS Registrar
    contacts = []
    
    # create some ORG contacts
    5.times do |i|
      code = "#{reg_code}:ORG:#{i+1}"
      name = "Mock Company #{reg_i+1}-#{i+1} OÜ"
      
      contact = Registrant.find_or_create_by!(code: code) do |c|
        c.name = name
        c.email = generate_email("info", "company#{reg_i+1}.#{i+1}")
        c.phone = generate_phone
        c.registrar = registrar
        c.country_code = 'EE'
        c.city = 'Tallinn'
        c.street = "Business St #{i+1}"
        c.zip = '10111'
        c.ident_country_code = 'EE'
        c.ident_type = 'org'
        c.ident = rand(10000000..99999999).to_s
      end
      contacts << contact
    end

    # create some PRIV contacts
    5.times do |i|
      code = "#{reg_code}:PRIV:#{i+1}"
      first_name = "Mockperson#{reg_i+1}"
      last_name = "Lastname#{i+1}"
      ident = generate_ident(sex: i.even? ? 'm' : 'f', birth_date: "9#{i}0101")
      
      contact = Registrant.find_or_create_by!(code: code) do |c|
        c.name = "#{first_name} #{last_name}"
        c.email = generate_email(first_name, last_name)
        c.phone = generate_phone
        c.registrar = registrar
        c.country_code = 'EE'
        c.city = 'Tartu'
        c.street = "Private St #{i+1}"
        c.zip = '51001'
        c.ident_country_code = 'EE'
        c.ident_type = 'priv'
        c.ident = ident
      end
      contacts << contact
    end
    puts "  Contacts created/found: #{contacts.count}"

    # 6. Create Domains for THIS Registrar and its Contacts
    10.times do |i|
      domain_name = "mock#{reg_i+1}-#{i+1}.#{zone_origin}"
      registrant = contacts.sample
      
      # Create Domain
      domain = Domain.find_or_create_by!(name: domain_name) do |d|
        d.registrar = registrar
        d.registrant = registrant
        d.period = 1
        d.period_unit = 'y'
        d.valid_to = 1.year.from_now

        # Add Admin Contacts (required)
        d.admin_contacts << registrant
        
        # Add Tech Contacts (required usually)
        d.tech_contacts << registrant

        # Add Nameservers (min 2 required)
        2.times do |j|
          ns_hostname = "ns#{j+1}.#{domain_name}"
          d.nameservers.build(
            hostname: ns_hostname,
            ipv4: ["192.0.2.#{i*10+j}"],
            ipv6: ["2001:db8::#{i*10+j}"]
          )
        end
      end
      
      if domain.persisted?
        puts "  Ensured domain: #{domain.name}"
      else
        puts "  Failed to ensure domain #{domain_name}: #{domain.errors.full_messages.join(', ')}"
      end
    end
  end

  # ============================================================
  # Stale Fallback Testing Data (registrant_center#165)
  # ============================================================
  #
  # TARA test user: MARY ANN O'CONNEZ-SUSLIK
  #   Personal code: 60001019906
  #   Phone (Mobile-ID): +37200000766
  #
  # Testing procedure:
  #   1. Run this seed: rails runner db/seeds_mock.rb
  #   2. Log into registrant center via TARA with 60001019906
  #   3. Open /api/v1/registrant/domains?tech=init
  #   4. You should see BOTH direct domains (maryann-*.ee) AND company-linked domains (acme-*.ee, globex-*.ee)
  #   5. To simulate business registry outage: change company_register_password to invalid value and restart
  #   6. Clear primary gem cache: Rails.cache.delete(gem_cache_key) — see below
  #   7. Reload domains listing — company-linked domains should still appear (stale fallback)
  #   8. After stale TTL expires (cache_period + 24h), company-linked domains will disappear
  #
  puts "=========================================="
  puts "Setting up Stale Fallback Test Data..."
  puts "=========================================="

  # Use existing registrar (MOCKREG1) for test domains
  test_registrar = Registrar.find_by!(code: "MOCKREG1")

  # RegistrantUser matching TARA test ID
  registrant_user = RegistrantUser.find_or_create_by!(registrant_ident: 'EE-60001019906') do |u|
    u.username = "MARY ANN O'CONNEZ-SUSLIK"
  end
  registrant_user.update!(username: "MARY ANN O'CONNEZ-SUSLIK")
  puts "  RegistrantUser: #{registrant_user.username} (#{registrant_user.registrant_ident})"

  # PRIV contact matching user's ident — for direct domains
  priv_contact = Registrant.find_or_create_by!(code: "TARA:PRIV:60001019906") do |c|
    c.name = "MARY ANN O'CONNEZ-SUSLIK"
    c.email = "maryann+mock@example.com"
    c.phone = '+372.50000766'
    c.registrar = test_registrar
    c.country_code = 'EE'
    c.city = 'Tallinn'
    c.street = 'Test St 1'
    c.zip = '10111'
    c.ident_country_code = 'EE'
    c.ident_type = 'priv'
    c.ident = '60001019906'
  end
  puts "  PRIV contact: #{priv_contact.name} (ident=#{priv_contact.ident})"

  # ORG contacts — for company-linked domains
  # These registration numbers come from CompanyRegister demo endpoint
  # for test user 60001019906 (test_mode: true in config/application.yml)
  mock_companies = [
    { reg_number: '12345678', name: 'Andmesilla DEMO OÜ', code: 'TARA:ORG:ANDMESILLA' },
    { reg_number: '10112390', name: 'SAUTEC AS', code: 'TARA:ORG:SAUTEC' },
    { reg_number: '10001880', name: 'OÜ Spider Autogrupp', code: 'TARA:ORG:SPIDER' },
  ]

  org_contacts = mock_companies.map do |company|
    contact = Registrant.find_or_create_by!(code: company[:code]) do |c|
      c.name = company[:name]
      c.email = "#{company[:name].parameterize}+mock@example.com"
      c.phone = generate_phone
      c.registrar = test_registrar
      c.country_code = 'EE'
      c.city = 'Tallinn'
      c.street = 'Business St 1'
      c.zip = '10111'
      c.ident_country_code = 'EE'
      c.ident_type = 'org'
      c.ident = company[:reg_number]
    end
    puts "  ORG contact: #{contact.name} (ident=#{contact.ident})"
    contact
  end

  # Direct domains — owned by PRIV contact (always visible)
  2.times do |i|
    domain_name = "maryann-#{i+1}.#{zone_origin}"
    domain = Domain.find_or_create_by!(name: domain_name) do |d|
      d.registrar = test_registrar
      d.registrant = priv_contact
      d.period = 1
      d.period_unit = 'y'
      d.valid_to = 1.year.from_now
      d.admin_contacts << priv_contact
      d.tech_contacts << priv_contact
      2.times do |j|
        d.nameservers.build(
          hostname: "ns#{j+1}.#{domain_name}",
          ipv4: ["192.0.2.#{100+i*10+j}"],
          ipv6: ["2001:db8::#{100+i*10+j}"]
        )
      end
    end
    puts "  Direct domain: #{domain.name} (registrant=#{priv_contact.name})" if domain.persisted?
  end

  # Company-linked domains — owned by ORG contacts (visible via company representation)
  org_contacts.each_with_index do |org_contact, ci|
    2.times do |i|
      prefix = org_contact.name.split.first.downcase
      domain_name = "#{prefix}-#{i+1}.#{zone_origin}"
      domain = Domain.find_or_create_by!(name: domain_name) do |d|
        d.registrar = test_registrar
        d.registrant = org_contact
        d.period = 1
        d.period_unit = 'y'
        d.valid_to = 1.year.from_now
        d.admin_contacts << org_contact
        d.tech_contacts << org_contact
        2.times do |j|
          d.nameservers.build(
            hostname: "ns#{j+1}.#{domain_name}",
            ipv4: ["192.0.2.#{200+ci*20+i*10+j}"],
            ipv6: ["2001:db8::#{200+ci*20+i*10+j}"]
          )
        end
      end
      puts "  Company domain: #{domain.name} (registrant=#{org_contact.name})" if domain.persisted?
    end
  end

  puts ""
  puts "  Test data summary:"
  puts "    User: EE-60001019906 (MARY ANN O'CONNEZ-SUSLIK)"
  puts "    Direct domains: maryann-1.ee, maryann-2.ee"
  puts "    Company domains (from demo business registry):"
  puts "      andmesilla-1.ee, andmesilla-2.ee (Andmesilla DEMO OÜ, reg=12345678)"
  puts "      sautec-1.ee, sautec-2.ee (SAUTEC AS, reg=10112390)"
  puts "      spider-1.ee, spider-2.ee (OÜ Spider Autogrupp, reg=10001880)"
  puts ""
  puts "  Prerequisites:"
  puts "    company_register_test_mode: 'true' in config/application.yml"
  puts ""
  puts "  Testing procedure:"
  puts "    1. Run this seed: rails runner db/seeds_mock.rb"
  puts "    2. Restart the app"
  puts "    3. Log in via TARA with 60001019906 (+37200000766 for Mobile-ID)"
  puts "    4. You should see 8 domains (2 direct + 6 company-linked)"
  puts "    5. To simulate outage: set company_register_password to 'invalid' and restart"
  puts "    6. Company-linked domains should still appear via stale cache"
  puts "    7. After stale TTL expires (cache_period + 24h) they will disappear"
  puts "=========================================="

  # Custom User requested by the user
  puts "Processing Custom Registrar: REG1..."
  custom_registrar = Registrar.find_or_create_by!(code: "REG1") do |r|
    r.name = "Registrar First AS"
    r.reg_no = "10300220"
    r.email = "registrar1@example.com"
    r.phone = "+37200000766"
    r.address_street = "Staging St 1"
    r.address_city = "Tallinn"
    r.address_zip = "10111"
    r.address_country_code = "EE"
    r.accounting_customer_code = "REG1"
    r.language = "en"
    r.reference_no = Billing::ReferenceNo.generate(owner: r) rescue "1234567"
  end
  custom_registrar.accounts.find_or_create_by!(account_type: Account::CASH, currency: 'EUR')
  
  api_user = ApiUser.find_or_create_by!(username: "Märi Änn R1") do |u|
    u.plain_text_password = "password"
    u.registrar = custom_registrar
    u.roles = ["super"] # From staging: roles=["super"]
    u.active = true
    u.identity_code = "60001019906"
  end

  # Allow the requested IP for this user
  custom_registrar.white_ips.find_or_create_by!(
    ipv4: '85.253.229.124',
    interfaces: ['api', 'registrar']
  )
  puts "  Custom Staging User & Registrar ensured!"
end

puts "Mock Data Generation Completed!"
