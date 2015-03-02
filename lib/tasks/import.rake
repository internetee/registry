namespace :import do
  desc 'Imports registrars'
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
    existing_address_ids = Address.pluck(:legacy_contact_id)
    user = "rake-#{`whoami`.strip} #{ARGV.join ' '}"
    count = 0

    Legacy::Contact.includes(:object_registry, :object, :object_registry => :registrar).find_each(batch_size: 10000).with_index do |x, index|
      next if existing_contact_ids.include?(x.id)
      next if existing_address_ids.include?(x.id)
      count += 1

      begin
        contacts << [
          x.object_registry.name,
          x.telephone.try(:strip),
          x.email.try(:strip),
          x.fax.try(:strip),
          x.try(:crdate),
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
    ActiveRecord::Base.connection.execute('UPDATE addresses SET contact_id = legacy_contact_id WHERE legacy_contact_id IS NOT NULL AND contact_id IS NULL')
    puts "-----> Imported #{count} new contacts in #{(Time.now.to_f - start).round(2)} seconds"
  end
end
