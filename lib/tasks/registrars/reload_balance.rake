namespace :registrars do
  desc 'Reloads balance of registrars'

  task reload_balance: :environment do
    include ActionView::Helpers::NumberHelper
    invoiced_registrar_count = 0

    # No transaction around the whole loop: one registrar's billing error must not roll back the others' invoices.
    Registrar.all.each do |registrar|
      balance_auto_reload_setting = registrar.settings['balance_auto_reload']
      next unless balance_auto_reload_setting

      reload_pending = balance_auto_reload_setting['pending']
      threshold_reached = registrar.balance <= balance_auto_reload_setting['type']['threshold']
      reload_amount = balance_auto_reload_setting['type']['amount']

      next if reload_pending || !threshold_reached

      Registrar.transaction do
        registrar.issue_prepayment_invoice(reload_amount, 'reload balance')
        registrar.settings['balance_auto_reload']['pending'] = true
        registrar.save!
      end

      puts %(Registrar "#{registrar}" got #{number_to_currency(reload_amount, unit: 'EUR')})
      invoiced_registrar_count += 1
    rescue StandardError => e
      puts %(Registrar "#{registrar}" balance reload failed: #{e.class}: #{e.message})
    end

    puts "Invoiced total: #{invoiced_registrar_count}"
  end
end
