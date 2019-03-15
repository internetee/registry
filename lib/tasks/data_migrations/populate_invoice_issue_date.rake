namespace :data_migrations do
  task populate_invoice_issue_date: [:environment] do
    processed_invoice_count = 0

    Invoice.transaction do
      Invoice.find_each do |invoice|
        invoice_issue_date = invoice.created_at.to_date
        invoice.update!(issue_date: invoice_issue_date)

        processed_invoice_count += 1
      end
    end

    puts "Invoices processed: #{processed_invoice_count}"
  end
end
