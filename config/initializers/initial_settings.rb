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
  Setting.save_default(:orphans_contacts_in_months, 6)
  Setting.save_default(:expire_pending_confirmation, 48)

  Setting.save_default(:ds_digest_type, 2)
  Setting.save_default(:ds_data_allowed, false)
  Setting.save_default(:key_data_allowed, true)

  Setting.save_default(:dnskeys_min_count, 0)
  Setting.save_default(:dnskeys_max_count, 9)
  Setting.save_default(:ns_min_count, 2)
  Setting.save_default(:ns_max_count, 11)

  Setting.save_default(:transfer_wait_time, 0)
  Setting.transfer_wait_time = 0
  Setting.save_default(:request_confrimation_on_registrant_change_enabled, true)
  Setting.save_default(:request_confirmation_on_domain_deletion_enabled, true)
  Setting.save_default(:address_processing, true)
  Setting.save_default(:default_language, 'en')
  Setting.save_default(:nameserver_required, false)

  Setting.save_default(:client_side_status_editing_enabled, false)

  Setting.save_default(:days_to_keep_business_registry_cache, 2)

  Setting.save_default(:invoice_number_min, 131050)
  Setting.save_default(:invoice_number_max, 149999)
  Setting.save_default(:directo_monthly_number_min,  309901)
  Setting.save_default(:directo_monthly_number_max,  309999)
  Setting.save_default(:directo_monthly_number_last, 309901)
  Setting.save_default(:days_to_keep_invoices_active, 30)
  Setting.save_default(:days_to_keep_overdue_invoices_active, 30)
  Setting.save_default(:minimum_deposit, 0.0)
  Setting.save_default(:directo_receipt_payment_term, "R")
  Setting.save_default(:directo_receipt_product_name, "ETTEM06")
  Setting.save_default(:directo_sales_agent, "JAANA")

  Setting.save_default(:days_to_renew_domain_before_expire, 90)
  Setting.save_default(:expire_warning_period, 15)
  Setting.save_default(:redemption_grace_period, 30)
  Setting.save_default(:expiration_reminder_mail, 2)

  Setting.save_default(:registrar_ip_whitelist_enabled, true)
  Setting.save_default(:api_ip_whitelist_enabled, true)

  Setting.save_default(:registry_juridical_name, 'Eesti Interneti SA')
  Setting.save_default(:registry_reg_no, '90010019')
  Setting.save_default(:registry_email, 'info@internet.ee')
  Setting.save_default(:registry_billing_email, 'info@internet.ee')
  Setting.save_default(:registry_phone, '+372 727 1000')
  Setting.save_default(:registry_country_code, 'EE')
  Setting.save_default(:registry_state, 'Harjumaa')
  Setting.save_default(:registry_street, 'Paldiski mnt 80')
  Setting.save_default(:registry_city, 'Tallinn')
  Setting.save_default(:registry_zip, '10617')
  Setting.save_default(:registry_vat_no, 'EE101286464')
  Setting.save_default(:registry_url, 'www.internet.ee')
  Setting.save_default(:registry_vat_prc, 0.2)
  Setting.save_default(:registry_iban, 'EE557700771000598731')
  Setting.save_default(:registry_bank, 'LHV Pank')
  Setting.save_default(:registry_bank_code, '689')
  Setting.save_default(:registry_swift, 'LHVBEE22')
  Setting.save_default(:registry_invoice_contact, 'Martti Õigus')
end

# dev only setting
EPP_LOG_ENABLED = true # !Rails.env.test?
