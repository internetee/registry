class RegenerateRegistrarReferenceNumbers < ActiveRecord::Migration[5.1]
  def up
    # processed_registrar_count = 0
    #
    # Registrar.transaction do
    #   Registrar.all.each do |registrar|
    #     next unless registrar.reference_no.start_with?('RF')
    #
    #     registrar.update_columns(reference_no: Billing::ReferenceNo.generate)
    #     processed_registrar_count += 1
    #   end
    # end
    #
    # puts "Registrars processed: #{processed_registrar_count}"
  end

  def down
  end
end
