namespace :import do
  desc 'Import registrars'
  task registrars: :environment do
    start = Time.now.to_f
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
        updator_str: user
      })
    end

    Registrar.import registrars, validate: false

    puts "-----> Imported #{count} new registrars in #{(Time.now.to_f - start).round(2)} seconds"
  end

  desc 'Import contacts'
  task contacts: :environment do
    start = Time.now.to_f
    puts '-----> Importing contacts...'

    # 1;"RC";"born number" # not used
    # 2;"OP";"identity card number" -> priv
    # 3;"PASS";"passwport" ->
    # 4;"ICO";"organization identification number"
    # 5;"MPSV";"social system identification" # not used
    # 6;"BIRTHDAY";"day of birth"

    ident_type_map = {
      2 => Contact::IDENT_PRIV,
      3 => Contact::IDENT_PASSPORT,
      4 => Contact::IDENT_TYPE_BIC,
      6 => Contact::IDENT_BIRTHDAY
    }

    contact_columns = [
      "code",
      "phone",
      "email",
      "fax",
      "created_at",
      "ident",
      "ident_type",
      "auth_info",
      "name",
      "org_name",
      "registrar_id",
      "creator_str",
      "updator_str",
      "ident_country_code",
      "legacy_id"
    ]

    address_columns = [
      "city",
      "street",
      "zip",
      "created_at",
      "street2",
      "street3",
      "creator_str",
      "updator_str",
      "country_code",
      "state",
      "legacy_contact_id"
    ]

    contacts, addresses = [], []
    existing_contact_ids = Contact.pluck(:legacy_id)
    user = "rake-#{`whoami`.strip} #{ARGV.join ' '}"
    count = 0

    Legacy::Contact.includes(:object_registry, :object, :object_registry => :registrar).find_each(batch_size: 10000).with_index do |x, index|
      next if existing_contact_ids.include?(x.id)
      count += 1

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
          x.name.try(:strip),
          x.organization.try(:strip),
          x.object_registry.try(:registrar).try(:id),
          user,
          user,
          x.country.try(:strip),
          x.id
        ]

        addresses << [
          x.city.try(:strip),
          x.street1.try(:strip),
          x.postalcode.try(:strip),
          x.object_registry.try(:crdate),
          x.street2.try(:strip),
          x.street3.try(:strip),
          user,
          user,
          x.country.try(:strip),
          x.stateorprovince.try(:strip),
          x.id
        ]

        if contacts.size % 10000 == 0
          Contact.import contact_columns, contacts, validate: false
          Address.import address_columns, addresses, validate: false
          contacts, addresses = [], []
        end
      rescue => e
        puts "ERROR on index #{index}"
        puts e
      end
    end

    Contact.import contact_columns, contacts, validate: false
    Address.import address_columns, addresses, validate: false

    puts '-----> Updating relations...'
    ActiveRecord::Base.connection.execute(
      "UPDATE addresses "\
      "SET contact_id = contacts.id "\
      "FROM contacts "\
      "WHERE contacts.legacy_id = legacy_contact_id "\
      "AND legacy_contact_id IS NOT NULL "\
      "AND contact_id IS NULL"
    )
    puts "-----> Imported #{count} new contacts in #{(Time.now.to_f - start).round(2)} seconds"
  end

  desc 'Import domains'
  task domains: :environment do
    start = Time.now.to_f
    puts '-----> Importing domains...'

    domain_columns = [
      "name",
      "registrar_id",
      "registered_at",
      "valid_from",
      "valid_to",
      "owner_contact_id",
      "auth_info",
      "created_at",
      "name_dirty",
      "name_puny",
      "period",
      "period_unit",
      "creator_str",
      "updator_str",
      "legacy_id"
    ]

    domain_contact_columns = [
      "contact_id",
      "domain_id",
      "contact_type",
      "created_at",
      "updated_at",
      "contact_code_cache",
      "creator_str",
      "updator_str",
      "legacy_domain_id"
    ]

    domain_status_columns = [
      "value",
      "creator_str",
      "updator_str",
      "legacy_domain_id"
    ]

    nameserver_columns = [
      "hostname",
      "ipv4",
      "ipv6",
      "creator_str",
      "updator_str",
      "legacy_domain_id"
    ]

    dnskey_columns = [
      "flags",
      "protocol",
      "alg",
      "public_key",
      "ds_alg",
      "ds_digest_type",
      "creator_str",
      "updator_str",
      "legacy_domain_id"
    ]



    domains, nameservers, dnskeys, domain_statuses, domain_contacts = [], [], [], [], []
    existing_domain_ids = Domain.pluck(:legacy_id)
    user = "rake-#{`whoami`.strip} #{ARGV.join ' '}"
    count = 0

    Legacy::Domain.includes(:object_registry, :object, :registrant, :nsset, :object_states, :dnskeys, :object_registry => :registrar).find_each(batch_size: 10000).with_index do |x, index|
      next if existing_domain_ids.include?(x.id)
      count += 1

      begin
        domains << [
          x.object_registry.name.try(:strip),
          x.object_registry.try(:registrar).try(:id),
          x.object_registry.try(:crdate),
          x.object_registry.try(:crdate),
          x.exdate,
          x.registrant.try(:id),
          x.object.authinfopw.try(:strip),
          x.object_registry.try(:crdate),
          x.object_registry.name.try(:strip),
          SimpleIDN.to_ascii(x.object_registry.name.try(:strip)),
          1,
          'y',
          user,
          user,
          x.id
        ]

        # domain contacts


        # domain statuses
        x.object_states.each do |state|
          domain_statuses << [
            state.name.try(:strip),
            user,
            user,
            x.id
          ]
        end

        # nameservers
        x.nsset.hosts.includes(:host_ipaddr_maps).each do |host|
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
        end

        x.dnskeys.each do |key|
          dnskeys << [
            key.flags,
            key.protocol,
            key.alg,
            key.key,
            3, # ds_alg
            Setting.ds_algorithm, # ds_digest_type
            user,
            user,
            x.id
          ]
        end

        if index % 10000 == 0 && index != 0
          puts 'importing'
          Domain.import domain_columns, domains, validate: false
          Nameserver.import nameserver_columns, nameservers, validate: false
          Dnskey.import dnskey_columns, dnskeys, validate: false
          DomainStatus.import domain_status_columns, domain_statuses, validate: false
          domains, nameservers, dnskeys, domain_statuses, domain_contacts = [], [], [], [], []
        end
      rescue => e
        binding.pry
      end
    end

    Domain.import domain_columns, domains, validate: false
    Nameserver.import nameserver_columns, nameservers, validate: false
    Dnskey.import dnskey_columns, dnskeys, validate: false
    DomainStatus.import domain_status_columns, domain_statuses, validate: false

    # puts '-----> Updating relations...'

    # puts '-----> Generating dnskey digests...'

    puts "-----> Imported #{count} new domains in #{(Time.now.to_f - start).round(2)} seconds"
  end
end
