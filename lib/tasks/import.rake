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
    Rake::Task['import:users'].invoke
    Rake::Task['import:contacts'].invoke
    Rake::Task['import:reserved'].invoke
    Rake::Task['import:domains'].invoke
    Rake::Task['import:zones'].invoke
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
        phone: x.telephone.try(:strip),
        email: x.email.try(:strip),
        billing_email: x.billing_address.try(:strip),
        country_code: x.country.try(:strip),
        state: x.stateorprovince.try(:strip),
        city: x.city.try(:strip),
        street: x.street1.try(:strip),
        zip: x.postalcode.try(:strip),
        url: x.url.try(:strip),
        accounting_customer_code: x.directo_handle.try(:strip),
        legacy_id: x.id,
        creator_str: user,
        updator_str: user,
        code: x.handle.upcase
      })
    end

    Registrar.import registrars, validate: false

    puts "-----> Generating reference numbers"

    Registrar.all.each do |x|
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

  desc 'Import users'
  task users: :environment do
    start = Time.zone.now.to_f
    puts "-----> Importing users and IP's..."

    id_users = []
    users = []
    ips = []
    temp = []

    existing_ids = ApiUser.pluck(:legacy_id)
    existing_ips = WhiteIp.pluck(:ipv4)

    Legacy::Registrar.all.each do |x|

      x.acl.all.each do |y|

        next if existing_ids.include?(y.id)

        if y.try(:cert) != 'pki'

          if y.try(:cert) == 'idkaart'
            id_users << ApiUser.new({
              username: y.try(:password) ? y.try(:password) : y.try(:password),
              plain_text_password: ('a'..'z').to_a.shuffle.first(8).join,
              identity_code: y.try(:password) ? y.try(:password) : y.try(:password),
              registrar_id: Registrar.find_by(legacy_id: x.try(:id)).try(:id),
              roles: ['billing'],
              legacy_id: y.try(:id)
              })
          else
            temp << ApiUser.new({
              username: x.handle.try(:strip),
              plain_text_password: y.try(:password) ? y.try(:password) : ('a'..'z').to_a.shuffle.first(8).join,
              registrar_id: Registrar.find_by(legacy_id: x.try(:id)).try(:id),
              roles: ['epp'],
              legacy_id: y.try(:id)
              })
          end
        end
        temp = temp.reverse!.uniq{|u| u.username }
      end
      users = temp

      x.acl.all.each do |y|
        next if existing_ips.include?(y.ipaddr)
        if !y.ipaddr.nil? && y.ipaddr != ''

          y.ipaddr.split(',').each do |ip|
            ips << WhiteIp.new({
              registrar_id: Registrar.find_by(legacy_id: x.try(:id)).try(:id),
              ipv4: ip,
              interfaces: ['api', 'registrar']
              })

          end
        end
      end
    end

    ApiUser.import id_users, validate: false
    ApiUser.import users, validate: false

    if ips
      WhiteIp.import ips, validate: false
    end

    puts "-----> Imported #{id_users.count} billing users and #{users.count} epp users"
    puts "-----> Imported #{ips.count} white IP's in #{(Time.zone.now.to_f - start).round(2)} seconds"

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
      4 => Contact::ORG,
      6 => Contact::BIRTHDAY
    }

    contact_columns = %w(
      code
      phone
      email
      fax
      created_at
      updated_at
      ident
      ident_type
      auth_info
      name
      registrar_id
      creator_str
      updator_str
      legacy_id
      street
      city
      zip
      state
      country_code
      statuses
    )

    contacts = []
    existing_contact_ids = Contact.pluck(:legacy_id)
    count = 0

    Legacy::Contact.includes(:object_registry, :object, object_registry: :registrar)
      .find_each(batch_size: 10000).with_index do |x, index|

      next if existing_contact_ids.include?(x.id)
      count += 1

      if 4 == x.ssntype
        name = x.organization.try(:strip).presence || x.name.try(:strip).presence
      else
        name = x.name.try(:strip).presence || x.organization.try(:strip).presence
      end

      begin
        contacts << [
          x.object_registry.name.try(:strip),
          x.telephone.try(:strip),
          [x.email.try(:strip), x.notifyemail.try(:strip)].uniq.select(&:present?).join(', '),
          x.fax.try(:strip),
          x.object_registry.try(:crdate),
          x.object.read_attribute(:update).nil? ? x.object_registry.try(:crdate) : x.object.read_attribute(:update),
          x.ssn.try(:strip),
          ident_type_map[x.ssntype],
          x.object.authinfopw.try(:strip),
          name,
          Registrar.find_by(legacy_id: x.object.try(:clid)).try(:id),
          x.object_registry.try(:registrar).try(:name),
          x.object.try(:registrar).try(:name) ? x.object.try(:registrar).try(:name) : x.object_registry.try(:registrar).try(:name),
          x.id,
          [x.street1.try(:strip), x.street2.try(:strip), x.street3.try(:strip)].compact.join(", "),
          x.city.try(:strip),
          x.postalcode.try(:strip),
          x.stateorprovince.try(:strip),
          x.country.try(:strip),
          [x.object_state.try(:name), Contact::OK].compact
        ]

        if contacts.size % 10000 == 0
          Contact.import contact_columns, contacts, {validate: false, timestamps: false}
          contacts = []
        end
      rescue => e
        puts "ERROR on index #{index}"
        puts e
      end
    end

    Contact.import contact_columns, contacts, {validate: false, timestamps: false}
    puts "-----> Imported #{count} new contacts in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end

  desc 'Import reserved'
  task reserved: :environment do
    start = Time.zone.now.to_f
    puts '-----> Importing reserved domains...'

    reserved_domains = []
    count = 0

    existing_ids = ReservedDomain.pluck(:legacy_id)

    Legacy::Domain.includes(
        :object_registry,
        :object
    ).find_each(batch_size: 1000).with_index do |x, index|

      next if existing_ids.include?(x.id) || Registrar.find_by(legacy_id: x.object.try(:clid)).try(:name) != 'eedirect'
      count += 1

      reserved_domains << ReservedDomain.new({
        created_at: x.object_registry.try(:crdate),
        updated_at: x.object.read_attribute(:update).nil? ? x.object_registry.try(:crdate) : x.object.read_attribute(:update),
        creator_str: x.object_registry.try(:registrar).try(:name),
        updator_str: x.object.try(:registrar).try(:name) ? x.object.try(:registrar).try(:name) : x.object_registry.try(:registrar).try(:name),
        names: '"' + x.object_registry.name.try(:strip) + '"=>"' + SecureRandom.hex + '"',
        legacy_id: x.id
      })

      if index % 1000 == 0 && index != 0
        ReservedDomain.import reserved_domains, {validate: false, timestamps: false}
        reserved_domains = []
      end
    end
    ReservedDomain.import reserved_domains, {validate: false, timestamps: false}
    puts "-----> Imported #{count} new reserved domains in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end

  desc 'Import domains'
  task domains: :environment do
    start = Time.zone.now.to_f
    puts '-----> Importing domains...'

    domain_columns = %w(
      name
      registrar_id
      registered_at
      valid_to
      transfer_code
      created_at
      updated_at
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

    domain_status_columns = %w(
      description
      value
      creator_str
      updator_str
      legacy_domain_id
    )

    nameserver_columns = %w(
      hostname
      ipv4
      ipv6
      creator_str
      updator_str
      legacy_domain_id
      created_at
      updated_at
    )

    dnskey_columns = %w(
      flags
      protocol
      alg
      public_key
      creator_str
      updator_str
      legacy_domain_id
      updated_at
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
      next if existing_domain_ids.include?(x.id) || Registrar.find_by(legacy_id: x.object.try(:clid)).try(:name) == 'eedirect'
      count += 1

      begin
        # domain statuses
        domain_statuses = []
        x.object_states.each do |state|
          next if state.name.blank?
          domain_statuses << state.name
        end

        # OK status is default
        domain_statuses << DomainStatus::OK if domain_statuses.empty?

        domains << [
          x.object_registry.name.try(:strip),
          Registrar.find_by(legacy_id: x.object.try(:clid)).try(:id),
          x.object_registry.try(:crdate),
          x.object_registry.try(:crdate),
          x.exdate,
          x.object.authinfopw.try(:strip),
          x.object_registry.try(:crdate),
          x.object.read_attribute(:update).nil? ? x.object_registry.try(:crdate) : x.object.read_attribute(:update),
          x.object_registry.name.try(:strip),
          SimpleIDN.to_ascii(x.object_registry.name.try(:strip)),
          1,
          'y',
          x.object_registry.try(:registrar).try(:name),
          x.object.try(:registrar).try(:name) ? x.object.try(:registrar).try(:name) : x.object_registry.try(:registrar).try(:name),
          x.id,
          x.object_registry.try(:crid),
          x.registrant,
          domain_statuses
        ]

        # admin contacts
        x.domain_contact_maps.each do |dc|
          domain_contacts << [
            'AdminDomainContact',
            x.object_registry.try(:registrar).try(:name),
            x.object.try(:registrar).try(:name) ? x.object.try(:registrar).try(:name) : x.object_registry.try(:registrar).try(:name),
            x.id,
            dc.contactid
          ]
        end

        # tech contacts
        x.nsset_contact_maps.each do |dc|
          domain_contacts << [
            'TechDomainContact',
            x.object_registry.try(:registrar).try(:name),
            x.object.try(:registrar).try(:name) ? x.object.try(:registrar).try(:name) : x.object_registry.try(:registrar).try(:name),
            x.id,
            dc.contactid
          ]
        end

        # nameservers
        nsset = x.nsset
        nsset.hosts.each do |host|
          ip_maps = host.host_ipaddr_maps
          ips = {
              ipv4: [],
              ipv6: [],
          }
          ip_maps.each do |ip_map|
            next unless ip_map.ipaddr
            ips[:ipv4] << ip_map.ipaddr.to_s.strip if ip_map.ipaddr.ipv4?
            ips[:ipv6] << ip_map.ipaddr.to_s.strip if ip_map.ipaddr.ipv6?
          end

          nameservers << [
            host.fqdn.try(:strip),
            ips[:ipv4],
            ips[:ipv6],
            x.object_registry.try(:registrar).try(:name),
            x.object.try(:registrar).try(:name) ? x.object.try(:registrar).try(:name) : x.object_registry.try(:registrar).try(:name),
            x.id,
            nsset.object_registry.try(:crdate),
            nsset.object_registry.try(:object_history).read_attribute(:update).nil? ? nsset.object_registry.try(:crdate) : nsset.object_registry.try(:object_history).read_attribute(:update)
          ]
        end if x.nsset && x.nsset.hosts

        x.dnskeys.each do |key|
          dnskeys << [
            key.flags,
            key.protocol,
            key.alg,
            key.key,
            x.object_registry.try(:registrar).try(:name),
            x.object.try(:registrar).try(:name) ? x.object.try(:registrar).try(:name) : x.object_registry.try(:registrar).try(:name),
            x.id,
            key.object_registry.try(:object_history).read_attribute(:update).nil? ? key.try(:crdate)||Time.zone.now : key.object_registry.try(:object_history).read_attribute(:update)
          ]
        end

        if index % 10000 == 0 && index != 0
          Domain.import domain_columns, domains, {validate: false, timestamps: false}
          Nameserver.import nameserver_columns, nameservers, {validate: false, timestamps: false}
          Dnskey.import dnskey_columns, dnskeys, {validate: false, timestamps: false}
          DomainContact.import domain_contact_columns, domain_contacts, validate: false # created_at is taken from contact at the bottom
          domains, nameservers, dnskeys, domain_contacts = [], [], [], []
        end
      rescue => e
        puts "ERROR on index #{index}"
        puts e
      end
    end

    Domain.import domain_columns, domains, {validate: false, timestamps: false}
    Nameserver.import nameserver_columns, nameservers, {validate: false, timestamps: false}
    Dnskey.import dnskey_columns, dnskeys, {validate: false, timestamps: false}
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
      "SET contact_id = contacts.id, "\
      "updated_at = contacts.updated_at, "\
      "created_at = contacts.created_at "\
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

    Dnskey.all.each do |ds|
      ds.generate_digest
      ds.generate_ds_key_tag
      ds.save(validate: false)
    end

    puts "-----> Imported #{count} new domains in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end

  desc 'Import zones'
  task zones: :environment do
    start = Time.zone.now.to_f
    puts '-----> Importing zones...'

    ns_records, a_records, a4_records = parse_zone_ns_data('ee', 1)

    DNS::Zone.create!({
      origin: 'ee',
      ttl: 43200,
      refresh: 3600,
      retry: 900,
      expire: 1209600,
      minimum_ttl: 3600,
      email: 'hostmaster.eestiinternet.ee',
      master_nameserver: 'ns.tld.ee',
      ns_records: ns_records,
      a_records: a_records,
      a4_records: a4_records
    })

    # edu.ee
    ns_records, a_records, a4_records = parse_zone_ns_data('edu.ee', 6)

    DNS::Zone.create!({
      origin: 'edu.ee',
      ttl: 43200,
      refresh: 3600,
      retry: 900,
      expire: 1209600,
      minimum_ttl: 3600,
      email: 'hostmaster.eestiinternet.ee',
      master_nameserver: 'ns.tld.ee',
      ns_records: ns_records,
      a_records: a_records,
      a4_records: a4_records
    })

    # aip.ee
    ns_records, a_records, a4_records = parse_zone_ns_data('aip.ee', 9)

    DNS::Zone.create!({
      origin: 'aip.ee',
      ttl: 43200,
      refresh: 3600,
      retry: 900,
      expire: 1209600,
      minimum_ttl: 3600,
      email: 'hostmaster.eestiinternet.ee',
      master_nameserver: 'ns.tld.ee',
      ns_records: ns_records,
      a_records: a_records,
      a4_records: a4_records
    })

    # org.ee
    ns_records, a_records, a4_records = parse_zone_ns_data('org.ee', 10)

    DNS::Zone.create!({
      origin: 'org.ee',
      ttl: 43200,
      refresh: 3600,
      retry: 900,
      expire: 1209600,
      minimum_ttl: 3600,
      email: 'hostmaster.eestiinternet.ee',
      master_nameserver: 'ns.tld.ee',
      ns_records: ns_records,
      a_records: a_records,
      a4_records: a4_records
    })

    # pri.ee
    ns_records, a_records, a4_records = parse_zone_ns_data('pri.ee', 2)

    DNS::Zone.create!({
      origin: 'pri.ee',
      ttl: 43200,
      refresh: 3600,
      retry: 900,
      expire: 1209600,
      minimum_ttl: 3600,
      email: 'hostmaster.eestiinternet.ee',
      master_nameserver: 'ns.tld.ee',
      ns_records: ns_records,
      a_records: a_records,
      a4_records: a4_records
    })

    # med.ee
    ns_records, a_records, a4_records = parse_zone_ns_data('med.ee', 3)

    DNS::Zone.create!({
      origin: 'med.ee',
      ttl: 43200,
      refresh: 3600,
      retry: 900,
      expire: 1209600,
      minimum_ttl: 3600,
      email: 'hostmaster.eestiinternet.ee',
      master_nameserver: 'ns.tld.ee',
      ns_records: ns_records,
      a_records: a_records,
      a4_records: a4_records
    })

    # fie.ee
    ns_records, a_records, a4_records = parse_zone_ns_data('fie.ee', 4)

    DNS::Zone.create!({
      origin: 'fie.ee',
      ttl: 43200,
      refresh: 3600,
      retry: 900,
      expire: 1209600,
      minimum_ttl: 3600,
      email: 'hostmaster.eestiinternet.ee',
      master_nameserver: 'ns.tld.ee',
      ns_records: ns_records,
      a_records: a_records,
      a4_records: a4_records
    })

    # com.ee
    ns_records, a_records, a4_records = parse_zone_ns_data('com.ee', 5)

    DNS::Zone.create!({
      origin: 'com.ee',
      ttl: 43200,
      refresh: 3600,
      retry: 900,
      expire: 1209600,
      minimum_ttl: 3600,
      email: 'hostmaster.eestiinternet.ee',
      master_nameserver: 'ns.tld.ee',
      ns_records: ns_records,
      a_records: a_records,
      a4_records: a4_records
    })

    # gov.ee
    ns_records, a_records, a4_records = parse_zone_ns_data('gov.ee', 7)

    DNS::Zone.create!({
      origin: 'gov.ee',
      ttl: 43200,
      refresh: 3600,
      retry: 900,
      expire: 1209600,
      minimum_ttl: 3600,
      email: 'hostmaster.eestiinternet.ee',
      master_nameserver: 'ns.tld.ee',
      ns_records: ns_records,
      a_records: a_records,
      a4_records: a4_records
    })

    # riik.ee
    ns_records, a_records, a4_records = parse_zone_ns_data('riik.ee', 8)

    DNS::Zone.create!({
      origin: 'riik.ee',
      ttl: 43200,
      refresh: 3600,
      retry: 900,
      expire: 1209600,
      minimum_ttl: 3600,
      email: 'hostmaster.eestiinternet.ee',
      master_nameserver: 'ns.tld.ee',
      ns_records: ns_records,
      a_records: a_records,
      a4_records: a4_records
    })

    puts "-----> Imported zones in #{(Time.zone.now.to_f - start).round(2)} seconds"
  end
end

def parse_zone_ns_data(domain, zone)
  ns_records = ''
  a_records = ''
  a4_records = ''
  Legacy::ZoneNs.where(zone: zone).each do |x|
    ipv4 = x.addrs.select { |addr| addr.ipv4? }.first
    ipv6 = x.addrs.select { |addr| addr.ipv6? }.first

    ns_records += "#{domain}. IN NS #{x.fqdn}.\n"
    a_records += "#{x.fqdn}. IN A #{ipv4}\n" if ipv4.present?
    a4_records += "#{x.fqdn}. IN AAAA #{ipv6}\n" if ipv6.present?
  end
  [ns_records.strip, a_records.strip, a4_records.strip]
end
