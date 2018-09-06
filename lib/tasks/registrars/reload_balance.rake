namespace :registrars do
  desc 'Reloads balance of registrars'

  task reload_balance: :environment do
    include ActionView::Helpers::NumberHelper
    invoiced_registrar_count = 0

    Registrar.transaction do
      Registrar.all.each do |registrar|
        balance_auto_reload_setting = registrar.settings['balance_auto_reload']
        next unless balance_auto_reload_setting

        reload_pending = balance_auto_reload_setting['pending']
        threshold_reached = registrar.balance <= balance_auto_reload_setting['type']['threshold']
        reload_amount = balance_auto_reload_setting['type']['amount']

        next if reload_pending || !threshold_reached

        Registrar.transaction do
          invoice = registrar.issue_prepayment_invoice(reload_amount)
          e_invoice = invoice.to_e_invoice
          e_invoice.deliver

          registrar.settings['balance_auto_reload']['pending'] = true
          registrar.save!
        end

        puts %(Registrar "#{registrar}" got #{number_to_currency(reload_amount, unit: 'EUR')})
        invoiced_registrar_count += 1
      end
    end

    puts "Invoiced total: #{invoiced_registrar_count}"
  end
end