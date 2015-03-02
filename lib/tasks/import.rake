namespace :import do
  desc 'Imports registrars'
  task registrars: :environment do
    puts '-----> Importing registrars...'

    Registrar.where('legacy_id IS NOT NULL').delete_all

    registrars = []
    existing_ids = Registrar.pluck(:legacy_id)

    Legacy::Registrar.all.each do |x|
      next if existing_ids.include?(x.id)

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
        creator_str: "rake-#{`whoami`.strip} #{ARGV.join ' '}",
        updator_str: "rake-#{`whoami`.strip} #{ARGV.join ' '}"
      })
    end

    Registrar.import registrars, validate: false

    puts '-----> Registrars imported'
  end

  desc 'Import contacts'
  task contacts: :environment do
    start = Time.now.to_i
    puts '-----> Importing contacts...'

    contacts = []
    existing_ids = Contact.pluck(:legacy_id)

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

    contacts = []

    Legacy::Contact.includes(:object_registry, :object, :registrar).find_each(batch_size: 10000) do |x|
      next if existing_ids.include?(x.id)
      begin
        # registrar = Registrar.find_by(legacy_id: x.object_registry.crid)

        contacts << Contact.new({
          code: x.object_registry.name,
          #type: , # not needed
          #reg_no: x.ssn.try(:strip),
          phone: x.telephone.try(:strip),
          email: x.email.try(:strip),
          fax: x.fax.try(:strip),
          ident: x.ssn.try(:strip),
          ident_type: ident_type_map[x.ssntype],
          #created_by_id: , # not needed
          #updated_by_id: , # not needed
          auth_info: x.object.authinfopw.try(:strip),
          name: x.name.try(:strip),
          org_name: x.organization.try(:strip),
          registrar_id: x.registrar.try(:id),
          creator_str: "rake-#{`whoami`.strip} #{ARGV.join ' '}",
          updator_str: "rake-#{`whoami`.strip} #{ARGV.join ' '}",
          ident_country_code: x.country.try(:strip),
          created_at: x.try(:crdate),
          legacy_id: x.id,
          address: Address.new({
            city: x.city.try(:strip),
            street: x.street1.try(:strip),
            zip: x.postalcode.try(:strip),
            street2: x.street2.try(:strip),
            street3: x.street3.try(:strip),
            creator_str: "rake-#{`whoami`.strip} #{ARGV.join ' '}",
            updator_str: "rake-#{`whoami`.strip} #{ARGV.join ' '}",
            country_code: x.country.try(:strip),
            state: x.stateorprovince.try(:strip)
          })
        })

        if contacts.size % 10000 == 0
          puts "commtting #{contacts.size}"
          puts Time.now.to_i - start
          # Contact.import contacts, validate: false
          contacts = []
        end
      rescue => e
        puts e
        puts x.inspect
      end
    end

    puts '-----> Contacts imported'
  end
end
