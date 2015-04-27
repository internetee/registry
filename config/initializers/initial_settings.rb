# otherwise rake not working 100%
begin
  con = ActiveRecord::Base.connection
rescue ActiveRecord::NoDatabaseError => e
  Rails.logger.info "Init settings didn't find database: #{e}"
end

if con.present? && con.table_exists?('settings')
  Setting.save_default(:admin_contacts_min_count, 1)
  Setting.save_default(:admin_contacts_max_count, 10)
  Setting.save_default(:tech_contacts_min_count, 1)
  Setting.save_default(:tech_contacts_max_count, 10)

  Setting.save_default(:ds_algorithm, 2)
  Setting.save_default(:ds_data_allowed, true)
  Setting.save_default(:key_data_allowed, true)

  Setting.save_default(:dnskeys_min_count, 0)
  Setting.save_default(:dnskeys_max_count, 9)
  Setting.save_default(:ns_min_count, 2)
  Setting.save_default(:ns_max_count, 11)

  Setting.save_default(:transfer_wait_time, 0)

  Setting.save_default(:client_side_status_editing_enabled, false)

  Setting.save_default(:eis_iban, 'EE557700771000598731')
  Setting.save_default(:eis_bank, 'LHV Pank')
  Setting.save_default(:eis_swift, 'LHVBEE22')
  Setting.save_default(:eis_invoice_contact, 'Martti Õigus')
  Setting.save_default(:invoice_number_min, '131050')
  Setting.save_default(:invoice_number_max, '149999')
  Setting.save_default(:days_to_keep_overdue_invoices_active, 30)
end

# dev only setting
EPP_LOG_ENABLED = true # !Rails.env.test?
