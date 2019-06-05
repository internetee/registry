namespace :data_migrations do
  task populate_invoice_vat_rate: :environment do
    processed_invoice_count = 0

    Invoice.transaction do
      Invoice.where(vat_rate: nil).find_each do |invoice|
        vat_rate = Invoice::VatRateCalculator.new(registrar: invoice.buyer).calculate
        invoice.update!(vat_rate: vat_rate)

        processed_invoice_count += 1
      end
    end

    puts "Invoices processed: #{processed_invoice_count}"
  end
end