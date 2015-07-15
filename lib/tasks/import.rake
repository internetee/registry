# rubocop: disable Style/SymbolProc
# rubocop: disable Performance/Detect
namespace :import do
  # README
  #
  # 1) ESTABLISH CONNECTION TO FRED DATABASE
  # ----------------------------------------
  #
  # Add 'fred' database connection settings to config/database.yml
  # Example config:
  #
  # fred:
  #   host: localhost
  #   adapter: postgresql
  #   encoding: unicode
  #   pool: 5
  #   username: fred
  #   password: fred
  #
  #  Verify you have correctly connected to fred database:
  #  Open Rails console:
  #
  #      cd your_registry_deploy_path/current/
  #      RAILS_ENV=production bundle exec rails c
  #      in console: Legacy::Contact.last
  #      in console: exit
  #
  #  In console you should get Last Legacy::Contact object.
  #  If you get any errors, scroll up and read first lines
  #  to figure out what went wrong to connect to fred database.
  #
  #
  #  2) START IMPORT
  #  ---------------
  #
  #  Import scrip does not write anything to fred database.
  #  Script is implemented this way, you can run it multiple times
  #  in case you need it. However already imported object are
  #  not reimported, thus if some object has been updated meanwhile
  #  in fred database, those updates will be missed and thous should
  #  be carried over manually. All new object in fred will be
  #  imported in multiple import script runs.
  #
  #  Start all import:
  #
  #      cd your_registry_deploy_path/current/
  #      RAILS_ENV=production bundle exec rails import:all
  #
  #  If you wish to import one by one, please follow individual import order
  #  from task 'Import all' tasks in this script.

  desc 'Import all'
  task all: :environment do
    Rake::Task['import:registrars'].invoke
    Rake::Task['import:contacts'].invoke
    Rake::Task['import:domains'].invoke
    Rake::Task['import:eis_domains'].invoke
  end

  desc 'Import registrars'
  task registrars: :environment do
    start = Time.zone.now.to_f
    puts '-----> Importing registrars...'

    registrars = []
    existing_ids = Registrar.pluck(:legacy_id)
    user = "rake-#{`whoami`.strip} #{ARGV.join ' '}"
    count = 0

    Legacy::Registrar.all.each do |x|
      next if existing_ids.include?(x.id)
      count += 1

      registrars << Registrar.new({
        name: x.organization.try(:strip).presence || x.name.try(:strip).presence || x.handle.try(:strip).presence,
        reg_no: x.ico.try(:strip),
        vat_no: x.dic.try(:strip),
        billing_address: nil,
        phone: x.telephone.try(:strip),
        email: x.email.try(:strip),
        billing_email: x.billing_address.try(:strip),
        country_code: x.country.try(:strip),
        state: x.stateorprovince.try(:strip),
        city: x.city.try(:strip),
        street: x.street1.try(:strip),
        zip: x.postalcode.try(:strip),
        url: x.url.try(:strip),
        directo_handle: x.directo_handle.try(:strip),
        vat: x.vat,
        legacy_id: x.id,
        creator_str: user,
        updator_str: user,
        code: x.handle.upcase
      })
    end

    Registrar.import registrars, validate: false

    puts "-----> Generating reference numbers"

    Registrar.all.each do |x|
      x.generate_iso_11649_reference_no
      x.save(validate: false)
    end

    puts "-----> Creating accounts numbers"

    Registrar.all.each do |x|
      next if x.cash_account
      x.accounts.create(account_type: Account::CASH, currency: 'EUR')
      x.save(validate: false)

      lr = Legacy::Registrar.find(x.legacy_id)
      x.cash_account.account_activities << AccountActivity.new({
        sum: lr.account_balance,
        currency: 'EUR',
        description: 'Transfer from legacy system'
      })

      x.cash_account.save
    end

    puts "-----> Imported #{count} new registrars in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end

  desc 'Import contacts'
  task contacts: :environment do
    start = Time.zone.now.to_f
    puts '-----> Importing contacts...'

    # 1;"RC";"born number" # not used
    # 2;"OP";"identity card number" -> priv
    # 3;"PASS";"passwport" ->
    # 4;"ICO";"organization identification number"
    # 5;"MPSV";"social system identification" # not used
    # 6;"BIRTHDAY";"day of birth"

    ident_type_map = {
      2 => Contact::PRIV,
      3 => Contact::PASSPORT,
      4 => Contact::BIC,
      6 => Contact::BIRTHDAY
    }

    contact_columns = %w(
      code
      phone
      email
      fax
      created_at
      ident
      ident_type
      auth_info
      name
      org_name
      registrar_id
      creator_str
      updator_str
      ident_country_code
      legacy_id
      street
      city
      zip
      state
      country_code
    )

    contacts = []
    existing_contact_ids = Contact.pluck(:legacy_id)
    user = "rake-#{`whoami`.strip} #{ARGV.join ' '}"
    count = 0

    Legacy::Contact.includes(:object_registry, :object, object_registry: :registrar)
      .find_each(batch_size: 10000).with_index do |x, index|

      next if existing_contact_ids.include?(x.id)
      count += 1

      name = x.name.try(:strip).presence || x.organization.try(:strip).presence
      begin
        contacts << [
          x.object_registry.name.try(:strip),
          x.telephone.try(:strip),
          x.email.try(:strip),
          x.fax.try(:strip),
          x.object_registry.try(:crdate),
          x.ssn.try(:strip),
          ident_type_map[x.ssntype],
          x.object.authinfopw.try(:strip),
          name,
          x.organization.try(:strip),
          x.object_registry.try(:registrar).try(:id),
          user,
          user,
          x.country.try(:strip),
          x.id,
          [x.street1.try(:strip), x.street2.try(:strip), x.street3.try(:strip)].join("\n"),
          x.city.try(:strip),
          x.postalcode.try(:strip),
          x.stateorprovince.try(:strip),
          x.country.try(:strip)
        ]

        if contacts.size % 10000 == 0
          Contact.import contact_columns, contacts, validate: false
          contacts = []
        end
      rescue => e
        puts "ERROR on index #{index}"
        puts e
      end
    end

    Contact.import contact_columns, contacts, validate: false
    puts "-----> Imported #{count} new contacts in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end

  desc 'Import domains'
  task domains: :environment do
    start = Time.zone.now.to_f
    puts '-----> Importing domains...'

    domain_columns = %w(
      name
      registered_at
      valid_from
      valid_to
      auth_info
      created_at
      name_dirty
      name_puny
      period
      period_unit
      creator_str
      updator_str
      legacy_id
      legacy_registrar_id
      legacy_registrant_id
      statuses
    )

    domain_contact_columns = %w(
      type
      creator_str
      updator_str
      legacy_domain_id
      legacy_contact_id
    )

    # rubocop: disable Lint/UselessAssignment
    domain_status_columns = %w(
      description
      value
      creator_str
      updator_str
      legacy_domain_id
    )
    # rubocop: enable Lint/UselessAssignment

    nameserver_columns = %w(
      hostname
      ipv4
      ipv6
      creator_str
      updator_str
      legacy_domain_id
    )

    dnskey_columns = %w(
      flags
      protocol
      alg
      public_key
      ds_alg
      ds_digest_type
      creator_str
      updator_str
      legacy_domain_id
    )

    domains, nameservers, dnskeys, domain_contacts = [], [], [], []
    existing_domain_ids = Domain.pluck(:legacy_id)
    user = "rake-#{`whoami`.strip} #{ARGV.join ' '}"
    count = 0

    Legacy::Domain.includes(
      :object_registry,
      :object,
      :nsset,
      :object_states,
      :dnskeys,
      :domain_contact_maps,
      nsset: { hosts: :host_ipaddr_maps }
    ).find_each(batch_size: 10000).with_index do |x, index|
      next if existing_domain_ids.include?(x.id)
      count += 1

      begin
        # domain statuses
        domain_statuses = []
        ok = true
        x.object_states.each do |state|
          next if state.name.blank?
          domain_statuses << state.name
          ok = false
        end

        # OK status is default
        domain_statuses << DomainStatus::OK if ok

        domains << [
          x.object_registry.name.try(:strip),
          x.object_registry.try(:crdate),
          x.object_registry.try(:crdate),
          x.exdate,
          x.object.authinfopw.try(:strip),
          x.object_registry.try(:crdate),
          x.object_registry.name.try(:strip),
          SimpleIDN.to_ascii(x.object_registry.name.try(:strip)),
          1,
          'y',
          user,
          user,
          x.id,
          x.object_registry.try(:crid),
          x.registrant,
          domain_statuses
        ]

        # admin contacts
        x.domain_contact_maps.each do |dc|
          domain_contacts << [
            'AdminDomainContact',
            user,
            user,
            x.id,
            dc.contactid
          ]
        end

        # tech contacts
        x.nsset_contact_maps.each do |dc|
          domain_contacts << [
            'TechDomainContact',
            user,
            user,
            x.id,
            dc.contactid
          ]
        end

        # nameservers
        x.nsset.hosts.each do |host|
          ip_maps = host.host_ipaddr_maps
          ips = {}
          ip_maps.each do |ip_map|
            next unless ip_map.ipaddr
            ips[:ipv4] = ip_map.ipaddr.to_s if ip_map.ipaddr.ipv4?
            ips[:ipv6] = ip_map.ipaddr.to_s if ip_map.ipaddr.ipv6?
          end if ip_maps.any?

          nameservers << [
            host.fqdn.try(:strip),
            ips[:ipv4].try(:strip),
            ips[:ipv6].try(:strip),
            user,
            user,
            x.id
          ]
        end if x.nsset && x.nsset.hosts

        x.dnskeys.each do |key|
          dnskeys << [
            key.flags,
            key.protocol,
            key.alg,
            key.key,
            3, # ds_alg
            1, # ds_digest_type /SHA1)
            user,
            user,
            x.id
          ]
        end

        if index % 10000 == 0 && index != 0
          Domain.import domain_columns, domains, validate: false
          Nameserver.import nameserver_columns, nameservers, validate: false
          Dnskey.import dnskey_columns, dnskeys, validate: false
          DomainContact.import domain_contact_columns, domain_contacts, validate: false
          domains, nameservers, dnskeys, domain_contacts = [], [], [], []
        end
      rescue => e
        puts "ERROR on index #{index}"
        puts e
      end
    end

    Domain.import domain_columns, domains, validate: false
    Nameserver.import nameserver_columns, nameservers, validate: false
    Dnskey.import dnskey_columns, dnskeys, validate: false
    DomainContact.import domain_contact_columns, domain_contacts, validate: false

    puts '-----> Updating relations...'

    # registrant
    ActiveRecord::Base.connection.execute(
      "UPDATE domains "\
      "SET registrant_id = contacts.id "\
      "FROM contacts "\
      "WHERE contacts.legacy_id = legacy_registrant_id "\
      "AND legacy_registrant_id IS NOT NULL "\
      "AND registrant_id IS NULL"
    )

    # registrar
    ActiveRecord::Base.connection.execute(
      "UPDATE domains "\
      "SET registrar_id = registrars.id "\
      "FROM registrars "\
      "WHERE registrars.legacy_id = legacy_registrar_id "\
      "AND legacy_registrar_id IS NOT NULL "\
      "AND registrar_id IS NULL"
    )

    # contacts
    ActiveRecord::Base.connection.execute(
      "UPDATE domain_contacts "\
      "SET contact_id = contacts.id "\
      "FROM contacts "\
      "WHERE contacts.legacy_id = legacy_contact_id "\
      "AND legacy_contact_id IS NOT NULL "\
      "AND contact_id IS NULL"
    )

    ActiveRecord::Base.connection.execute(
      "UPDATE domain_contacts "\
      "SET domain_id = domains.id "\
      "FROM domains "\
      "WHERE domains.legacy_id = legacy_domain_id "\
      "AND legacy_domain_id IS NOT NULL "\
      "AND domain_id IS NULL"
    )

    # nameservers
    ActiveRecord::Base.connection.execute(
      "UPDATE nameservers "\
      "SET domain_id = domains.id "\
      "FROM domains "\
      "WHERE domains.legacy_id = legacy_domain_id "\
      "AND legacy_domain_id IS NOT NULL "\
      "AND domain_id IS NULL"
    )

    # dnskeys
    ActiveRecord::Base.connection.execute(
      "UPDATE dnskeys "\
      "SET domain_id = domains.id "\
      "FROM domains "\
      "WHERE domains.legacy_id = legacy_domain_id "\
      "AND legacy_domain_id IS NOT NULL "\
      "AND domain_id IS NULL"
    )

    puts '-----> Generating dnskey digests...'

    Dnskey.all.each do |x|
      x.generate_digest
      x.generate_ds_key_tag
      x.save(validate: false)
    end

    puts "-----> Imported #{count} new domains in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end

  desc 'Import EIS domains'
  task eis_domains: :environment do
    start = Time.zone.now.to_f
    puts '-----> Importing EIS domains...'

    eis = Registrar.where(
      name: 'EIS',
      reg_no: '90010019',
      phone: '+3727271000',
      country_code: 'EE',
      vat_no: 'EE101286464',
      email: 'info@internet.ee',
      state: 'Harjumaa',
      city: 'Tallinn',
      street: 'Paldiski mnt 80',
      zip: '10617',
      url: 'www.internet.ee',
      code: 'EIS'
    ).first_or_create!

    unless eis.cash_account
      eis.accounts.create(account_type: Account::CASH, currency: 'EUR')
      eis.save
    end

    c = Registrant.where(
      name: 'Eesti Interneti Sihtasutus',
      phone: '+372.7271000',
      email: 'info@internet.ee',
      ident: '90010019',
      ident_type: 'passport',
      city: 'Tallinn',
      country_code: 'ee',
      street: 'Paldiski mnt 80',
      zip: '10617',
      registrar: eis
    ).first_or_create!

    # ee
    ns_list = []
    Legacy::ZoneNs.where(zone: 1).each do |x|
      ipv4 = x.addrs.select { |addr| addr.ipv4? }.first
      ipv6 = x.addrs.select { |addr| addr.ipv6? }.first
      ns_list << Nameserver.new(hostname: x.fqdn, ipv4: ipv4, ipv6: ipv6)
    end

    Domain.create!(
      name: 'ee',
      valid_to: Date.new(9999, 1, 1),
      period: 1,
      period_unit: 'y',
      registrant: c,
      nameservers: ns_list,
      admin_contacts: [c],
      tech_contacts: [c],
      registrar: eis
    )

    # edu.ee
    ns_list = []
    Legacy::ZoneNs.where(zone: 6).each do |x|
      ipv4 = x.addrs.select { |addr| addr.ipv4? }.first
      ipv6 = x.addrs.select { |addr| addr.ipv6? }.first
      ns_list << Nameserver.new(hostname: x.fqdn, ipv4: ipv4, ipv6: ipv6)
    end

    Domain.create!(
      name: 'edu.ee',
      valid_to: Date.new(9999, 1, 1),
      period: 1,
      period_unit: 'y',
      registrant: c,
      nameservers: ns_list,
      admin_contacts: [c],
      tech_contacts: [c],
      registrar: eis
    )

    # aip.ee
    ns_list = []
    Legacy::ZoneNs.where(zone: 9).each do |x|
      ipv4 = x.addrs.select { |addr| addr.ipv4? }.first
      ipv6 = x.addrs.select { |addr| addr.ipv6? }.first
      ns_list << Nameserver.new(hostname: x.fqdn, ipv4: ipv4, ipv6: ipv6)
    end

    Domain.create!(
      name: 'aip.ee',
      valid_to: Date.new(9999, 1, 1),
      period: 1,
      period_unit: 'y',
      registrant: c,
      nameservers: ns_list,
      admin_contacts: [c],
      tech_contacts: [c],
      registrar: eis
    )

    # org.ee
    ns_list = []
    Legacy::ZoneNs.where(zone: 10).each do |x|
      ipv4 = x.addrs.select { |addr| addr.ipv4? }.first
      ipv6 = x.addrs.select { |addr| addr.ipv6? }.first
      ns_list << Nameserver.new(hostname: x.fqdn, ipv4: ipv4, ipv6: ipv6)
    end

    Domain.create!(
      name: 'org.ee',
      valid_to: Date.new(9999, 1, 1),
      period: 1,
      period_unit: 'y',
      registrant: c,
      nameservers: ns_list,
      admin_contacts: [c],
      tech_contacts: [c],
      registrar: eis
    )

    # pri.ee
    ns_list = []
    Legacy::ZoneNs.where(zone: 2).each do |x|
      ipv4 = x.addrs.select { |addr| addr.ipv4? }.first
      ipv6 = x.addrs.select { |addr| addr.ipv6? }.first
      ns_list << Nameserver.new(hostname: x.fqdn, ipv4: ipv4, ipv6: ipv6)
    end

    Domain.create!(
      name: 'pri.ee',
      valid_to: Date.new(9999, 1, 1),
      period: 1,
      period_unit: 'y',
      registrant: c,
      nameservers: ns_list,
      admin_contacts: [c],
      tech_contacts: [c],
      registrar: eis
    )

    # med.ee
    ns_list = []
    Legacy::ZoneNs.where(zone: 3).each do |x|
      ipv4 = x.addrs.select { |addr| addr.ipv4? }.first
      ipv6 = x.addrs.select { |addr| addr.ipv6? }.first
      ns_list << Nameserver.new(hostname: x.fqdn, ipv4: ipv4, ipv6: ipv6)
    end

    Domain.create!(
      name: 'med.ee',
      valid_to: Date.new(9999, 1, 1),
      period: 1,
      period_unit: 'y',
      registrant: c,
      nameservers: ns_list,
      admin_contacts: [c],
      tech_contacts: [c],
      registrar: eis
    )

    # fie.ee
    ns_list = []
    Legacy::ZoneNs.where(zone: 4).each do |x|
      ipv4 = x.addrs.select { |addr| addr.ipv4? }.first
      ipv6 = x.addrs.select { |addr| addr.ipv6? }.first
      ns_list << Nameserver.new(hostname: x.fqdn, ipv4: ipv4, ipv6: ipv6)
    end

    Domain.create!(
      name: 'fie.ee',
      valid_to: Date.new(9999, 1, 1),
      period: 1,
      period_unit: 'y',
      registrant: c,
      nameservers: ns_list,
      admin_contacts: [c],
      tech_contacts: [c],
      registrar: eis
    )

    # com.ee
    ns_list = []
    Legacy::ZoneNs.where(zone: 5).each do |x|
      ipv4 = x.addrs.select { |addr| addr.ipv4? }.first
      ipv6 = x.addrs.select { |addr| addr.ipv6? }.first
      ns_list << Nameserver.new(hostname: x.fqdn, ipv4: ipv4, ipv6: ipv6)
    end

    Domain.create!(
      name: 'com.ee',
      valid_to: Date.new(9999, 1, 1),
      period: 1,
      period_unit: 'y',
      registrant: c,
      nameservers: ns_list,
      admin_contacts: [c],
      tech_contacts: [c],
      registrar: eis
    )

    # gov.ee
    ns_list = []
    Legacy::ZoneNs.where(zone: 7).each do |x|
      ipv4 = x.addrs.select { |addr| addr.ipv4? }.first
      ipv6 = x.addrs.select { |addr| addr.ipv6? }.first
      ns_list << Nameserver.new(hostname: x.fqdn, ipv4: ipv4, ipv6: ipv6)
    end

    Domain.create!(
      name: 'gov.ee',
      valid_to: Date.new(9999, 1, 1),
      period: 1,
      period_unit: 'y',
      registrant: c,
      nameservers: ns_list,
      admin_contacts: [c],
      tech_contacts: [c],
      registrar: eis
    )

    # riik.ee
    ns_list = []
    Legacy::ZoneNs.where(zone: 8).each do |x|
      ipv4 = x.addrs.select { |addr| addr.ipv4? }.first
      ipv6 = x.addrs.select { |addr| addr.ipv6? }.first
      ns_list << Nameserver.new(hostname: x.fqdn, ipv4: ipv4, ipv6: ipv6)
    end

    Domain.create!(
      name: 'riik.ee',
      valid_to: Date.new(9999, 1, 1),
      period: 1,
      period_unit: 'y',
      registrant: c,
      nameservers: ns_list,
      admin_contacts: [c],
      tech_contacts: [c],
      registrar: eis
    )

    puts "-----> Imported EIS domains in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end
end
# rubocop: enable Performance/Detect
# rubocop: enable Style/SymbolProc
