namespace :import do
  desc "Imports registrars"
  task registrars: :environment do
    puts '-----> Importing registrars...'

    # Registrar.where('legacy_id IS NOT NULL').delete_all

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
        legacy_id: x.id
      })
    end

    Registrar.import registrars, validate: false

    puts '-----> Registrars imported'
  end
end
