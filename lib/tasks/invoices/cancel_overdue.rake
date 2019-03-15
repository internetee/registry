namespace :invoices do
  task cancel_overdue: :environment do
    cancelled_invoice_count = 0

    canceller = OverdueInvoiceCanceller.new
    canceller.cancel do |invoice|
      puts "Invoice ##{invoice.id} is cancelled"
      cancelled_invoice_count += 1
    end

    puts "Cancelled total: #{cancelled_invoice_count}"
  end
end