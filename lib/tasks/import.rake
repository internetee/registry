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

  # desc 'Import contacts'
  # task contact: :environment do
  #   puts '-----> Importing contacts...'

  #   contacts = []
  #   existing_ids = Contact.pluck(:legacy_id)

  #   Legacy::Contact.all.each do |x|
  #     next if existing_ids.include?(x.id)

  #     1;"RC";"born number"
  #     2;"OP";"identity card number" -> priv
  #     3;"PASS";"passwport" ->
  #     4;"ICO";"organization identification number"
  #     5;"MPSV";"social system identification"
  #     6;"BIRTHDAY";"day of birth"

  #     contacts << Contact.new({
  #       code: ,
  #       #type: , # not needed
  #       #reg_no: x.ssn.try(:strip),
  #       phone: x.telephone.try(:strip),
  #       email: x.email.try(:strip),
  #       fax: x.fax.try(:strip),
  #       ident: x.ssn.try(:strip),
  #       ident_type: ,
  #       #created_by_id: , # not needed
  #       #updated_by_id: , # not needed
  #       auth_info: ,
  #       name: x.name.try(:strip),
  #       org_name: x.organization.try(:strip),
  #       registrar_id: ,
  #       creator_str: "rake-#{`whoami`.strip} #{ARGV.join ' '}",
  #       updator_str: "rake-#{`whoami`.strip} #{ARGV.join ' '}"
  #       ident_country_code: x.country.try(:strip),
  #       legacy_id: x.id
  #     })
  #   end

  #   puts '-----> Contacts imported'
  # end
end
