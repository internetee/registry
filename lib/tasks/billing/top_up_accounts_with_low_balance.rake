namespace :billing do
  desc 'Invoice registrars with low balance'

  task top_up_accounts_with_low_balance: :environment do
    if ENV['auto_account_top_up'] == 'false'
      $stderr.puts 'Feature is disabled, aborting.'
      next
    end

    invoiced_registrar_count = 0
    issued_invoices = []

    Registrar.transaction do
      Registrar.all.each do |registrar|
        next unless registrar.auto_account_top_up_activated?
        next if registrar.balance > registrar.auto_account_top_up_low_balance_threshold

        has_unpaid_auto_generated_invoices = registrar.invoices
                                               .joins("LEFT JOIN #{AccountActivity.table_name} activities" \
                                                    " ON (activities.invoice_id = #{Invoice.table_name}.id)")
                                               .where(cancelled_at: nil)
                                               .where(auto_generated: true)
                                               .having('COUNT(activities.id) = 0')
                                               .group('invoices.id').any?
        next if has_unpaid_auto_generated_invoices

        invoice_amount = registrar.auto_account_top_up_amount
        invoice = registrar.issue_prepayment_invoice(invoice_amount, nil, auto_generated: true)
        issued_invoices << invoice

        puts %Q(Registrar "#{registrar}" has been invoiced to #{format('%.2f', invoice_amount)})
        invoiced_registrar_count += 1
      end

      if issued_invoices.any?
        delivery_method = Invoice::DeliveryMethods::EInvoice.new
        delivery_method.deliver(issued_invoices)
      end
    end

    puts "Invoiced total: #{invoiced_registrar_count}"
  end
end
