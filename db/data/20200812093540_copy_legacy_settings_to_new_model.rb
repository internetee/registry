class CopyLegacySettingsToNewModel < ActiveRecord::Migration[6.0]
  def up
    validation_group =
      %w[admin_contacts_min_count admin_contacts_max_count tech_contacts_min_count ns_min_count
         tech_contacts_max_count orphans_contacts_in_months key_data_allowed dnskeys_min_count
         dnskeys_max_count nameserver_required expire_pending_confirmation ds_data_allowed
         legal_document_is_mandatory ns_max_count].freeze

    expiration_group =
      %w[days_to_renew_domain_before_expire expire_warning_period redemption_grace_period
         expiration_reminder_mail].freeze

    billing_group =
      %w[invoice_number_min invoice_number_max directo_monthly_number_min
         directo_monthly_number_last days_to_keep_invoices_active directo_monthly_number_max
         days_to_keep_overdue_invoices_active minimum_deposit directo_receipt_payment_term
         directo_receipt_product_name directo_sales_agent registry_billing_email
         registry_invoice_contact registry_vat_no registry_vat_prc registry_bank
         registry_iban registry_swift directo_monthly_number_max registry_bank_code].freeze

    contacts_group =
      %w[registry_juridical_name registry_reg_no registry_email registry_phone registry_url
         registry_street registry_city registry_state registry_zip registry_country_code
         registry_whois_disclaimer].freeze

    integer_vars =
      %w[admin_contacts_min_count admin_contacts_max_count tech_contacts_min_count
         tech_contacts_max_count orphans_contacts_in_months ds_digest_type dnskeys_min_count
         dnskeys_max_count ns_min_count ns_max_count transfer_wait_time invoice_number_min
         invoice_number_max days_to_keep_invoices_active days_to_keep_overdue_invoices_active
         days_to_renew_domain_before_expire expire_warning_period redemption_grace_period
         expire_pending_confirmation dispute_period_in_months].freeze

    float_vars = %w[registry_vat_prc minimum_deposit].freeze

    boolean_vars =
      %w[
        ds_data_allowed
        key_data_allowed
        client_side_status_editing_enabled
        registrar_ip_whitelist_enabled
        api_ip_whitelist_enabled
        request_confrimation_on_registrant_change_enabled
        request_confirmation_on_domain_deletion_enabled
        nameserver_required
        address_processing
        legal_document_is_mandatory
      ].freeze

    sql = 'SELECT var, value, created_at, updated_at, creator_str, updator_str FROM' \
          ' settings ORDER BY settings.id ASC'
    old_settings = ActiveRecord::Base.connection.execute(sql)

    old_settings.each do |origin|
      next if origin['var'] == 'days_to_keep_business_registry_cache'
      entry = SettingEntry.find_or_initialize_by(code: origin['var'])
      entry[:format] = 'string'
      entry[:format] = 'boolean' if boolean_vars.include? entry.code
      entry[:format] = 'float' if float_vars.include? entry.code
      entry[:format] = 'integer' if integer_vars.include? entry.code

      entry[:group] = 'other'
      entry[:group] = 'domain_validation' if validation_group.include? entry.code
      entry[:group] = 'domain_expiration' if expiration_group.include? entry.code
      entry[:group] = 'billing' if billing_group.include? entry.code
      entry[:group] = 'contacts' if contacts_group.include? entry.code

      %w[value created_at updated_at creator_str updator_str].each do |field|
        entry[field] = origin[field]
        next if field != 'value'

        entry.value = origin[field].gsub('--- ', '').strip.gsub("'", '')
      end

      if entry.save
        logger.info "Legacy setting '#{entry.code}' successfully migrated to SettingEntry"
      else
        logger.error "!!! Failed to migrate setting '#{entry.code}': " \
        "#{entry.errors.full_messages.join(', ')}"
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
