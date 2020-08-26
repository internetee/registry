# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
ActiveRecord::Base.transaction do
  # Create dynamic Setting objects
  SettingEntry.create(code: 'registry_vat_prc', value: '0.2', format: 'float', group: 'billing')
  SettingEntry.create(code: 'directo_sales_agent', value: 'HELEN', format: 'string', group: 'billing')
  SettingEntry.create(code: 'admin_contacts_min_count', value: '1', format: 'integer', group: 'domain_validation')
  SettingEntry.create(code: 'admin_contacts_max_count', value: '10', format: 'integer', group: 'domain_validation')
  SettingEntry.create(code: 'tech_contacts_min_count', value: '1', format: 'integer', group: 'domain_validation')
  SettingEntry.create(code: 'tech_contacts_max_count', value: '10', format: 'integer', group: 'domain_validation')
  SettingEntry.create(code: 'orphans_contacts_in_months', value: '6', format: 'integer', group: 'domain_validation')
  SettingEntry.create(code: 'ds_data_allowed', value: 'false', format: 'boolean', group: 'domain_validation')
  SettingEntry.create(code: 'key_data_allowed', value: 'true', format: 'boolean', group: 'domain_validation')
  SettingEntry.create(code: 'dnskeys_min_count', value: '0', format: 'integer', group: 'domain_validation')
  SettingEntry.create(code: 'dnskeys_max_count', value: '9', format: 'integer', group: 'domain_validation')
  SettingEntry.create(code: 'nameserver_required', value: 'false', format: 'boolean', group: 'domain_validation')
  SettingEntry.create(code: 'ns_min_count', value: '2', format: 'integer', group: 'domain_validation')
  SettingEntry.create(code: 'ns_max_count', value: '11', format: 'integer', group: 'domain_validation')
  SettingEntry.create(code: 'expire_pending_confirmation', value: '48', format: 'integer', group: 'domain_validation')
  SettingEntry.create(code: 'days_to_renew_domain_before_expire', value: '90', format: 'integer', group: 'domain_expiration')
  SettingEntry.create(code: 'expire_warning_period', value: '15', format: 'integer', group: 'domain_expiration')
  SettingEntry.create(code: 'redemption_grace_period', value: '30', format: 'integer', group: 'domain_expiration')
  SettingEntry.create(code: 'transfer_wait_time', value: '0', format: 'integer', group: 'other')
  SettingEntry.create(code: 'ds_digest_type', value: '2', format: 'integer', group: 'other')
  SettingEntry.create(code: 'client_side_status_editing_enabled', value: 'false', format: 'boolean', group: 'other')
  SettingEntry.create(code: 'api_ip_whitelist_enabled', value: 'false', format: 'boolean', group: 'other')
  SettingEntry.create(code: 'registrar_ip_whitelist_enabled', value: 'false', format: 'boolean', group: 'other')
  SettingEntry.create(code: 'request_confrimation_on_registrant_change_enabled', value: 'true', format: 'boolean', group: 'other')
  SettingEntry.create(code: 'request_confirmation_on_domain_deletion_enabled', value: 'true', format: 'boolean', group: 'other')
  SettingEntry.create(code: 'default_language', value: 'en', format: 'string', group: 'other')
  SettingEntry.create(code: 'invoice_number_min', value: '131050', format: 'integer', group: 'billing')
  SettingEntry.create(code: 'invoice_number_max', value: '149999', format: 'integer', group: 'billing')
  SettingEntry.create(code: 'days_to_keep_invoices_active', value: '30', format: 'integer', group: 'billing')
  SettingEntry.create(code: 'days_to_keep_overdue_invoices_active', value: '0', format: 'integer', group: 'billing')
  SettingEntry.create(code: 'minimum_deposit', value: '0.0', format: 'float', group: 'billing')
  SettingEntry.create(code: 'directo_receipt_payment_term', value: 'R', format: 'string', group: 'billing')
  SettingEntry.create(code: 'directo_receipt_product_name', value: 'ETTEM06', format: 'string', group: 'billing')
  SettingEntry.create(code: 'registry_billing_email', value: 'info@internet.ee', format: 'string', group: 'billing')
  SettingEntry.create(code: 'registry_invoice_contact', value: 'Martti Õigus', format: 'string', group: 'billing')
  SettingEntry.create(code: 'registry_vat_no', value: 'EE101286464', format: 'string', group: 'billing')
  SettingEntry.create(code: 'registry_bank', value: 'LHV Pank', format: 'string', group: 'billing')
  SettingEntry.create(code: 'registry_iban', value: 'EE557700771000598731', format: 'string', group: 'billing')
  SettingEntry.create(code: 'registry_swift', value: 'LHVBEE22', format: 'string', group: 'billing')
  SettingEntry.create(code: 'registry_email', value: 'info@internet.ee', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'registry_phone', value: '+372 727 1000', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'registry_url', value: 'www.internet.ee', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'registry_street', value: 'Paldiski mnt 80', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'registry_city', value: 'Tallinn', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'registry_state', value: 'Harjumaa', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'registry_country_code', value: 'EE', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'expiration_reminder_mail', value: '2', format: 'integer', group: 'domain_expiration')
  SettingEntry.create(code: 'directo_monthly_number_min', value: '309901', format: 'integer', group: 'billing')
  SettingEntry.create(code: 'directo_monthly_number_max', value: '309999', format: 'integer', group: 'billing')
  SettingEntry.create(code: 'registry_bank_code', value: '689', format: 'string', group: 'billing')
  SettingEntry.create(code: 'registry_reg_no', value: '90010019', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'registry_zip', value: '10617', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'registry_juridical_name', value: 'Eesti Interneti SA', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'address_processing', value: 'true', format: 'boolean', group: 'other')
  SettingEntry.create(code: 'directo_monthly_number_last', value: '309901', format: 'integer', group: 'billing')
  SettingEntry.create(code: 'dispute_period_in_months', value: '36', format: 'integer', group: 'other')
  SettingEntry.create(code: 'registry_whois_disclaimer', value: 'Search results may not be used for commercial, advertising, recompilation, repackaging,  redistribution, reuse, obscuring or other similar activities.', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'legal_document_is_mandatory', value: 'true', format: 'boolean', group: 'domain_validation')

  AdminUser.where(username: 'admin').first_or_create!(
    username: 'admin',
    email: 'admin@domain.tld',
    password: 'adminadmin',
    password_confirmation: 'adminadmin',
    identity_code: '38001085718',
    country_code: 'EE',
    roles: ['admin']
  )

  # First registrar
  Registrar.where(name: 'Registrar First').first_or_create!(
    name: 'Registrar First',
    reg_no: '90010019',
    accounting_customer_code: '1234',
    language: 'EE',
    reference_no: '11',
    #    vat_rate: '0.2',
    vat_no: 'EE101286464',
    address_country_code: 'EE',
    address_state: 'Harjumaa',
    address_city: 'Tallinn',
    address_street: 'Tänav 1',
    address_zip: '1234546',
    email: 'registrar@first.tld',
    code: 'REG1'
  )

#  registrar.accounts.create!(account_type: Account::CASH, currency: 'EUR')

#  ApiUser.create!(
#    username: 'api_first',
#    password: 'api_first',
#    identity_code: '38001085718',
#    active: true,
#    registrar: registrar,
#    roles: ['epp']
#  )



#  ZonefileSetting.create!(
#    origin: 'tld',
#    ttl: 43200,
#    refresh: 3600,
#    retry: 900,
#    expire: 1209600,
#    minimum_ttl: 3600,
#    email: 'admin.domain.tld',
#    master_nameserver: 'ns.tld'
#  )
end
