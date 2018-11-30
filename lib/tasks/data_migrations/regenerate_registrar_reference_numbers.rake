namespace :data_migrations do
  task regenerate_registrar_reference_numbers: [:environment] do
    processed_registrar_count = 0

    Registrar.transaction do
      Registrar.all.each do |registrar|
        next unless registrar.reference_no.start_with?('RF')

        registrar.reference_no = Billing::ReferenceNo.generate
        registrar.save!

        processed_registrar_count += 1
      end
    end

    puts "Registrars processed: #{processed_registrar_count}"
  end
end
