namespace :data_migrations do
  task populate_invoice_vat_rate: :environment do
    processed_invoice_count = 0

    Invoice.transaction do
      Invoice.where(vat_rate: nil).find_each do |invoice|
        invoice.update_columns(vat_rate: invoice.buyer.effective_vat_rate)
        processed_invoice_count += 1
      end
    end

    puts "Invoices processed: #{processed_invoice_count}"
  end
end