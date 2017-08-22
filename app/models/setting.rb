class Setting < RailsSettings::CachedSettings
  include Versions # version/setting_version.rb

  def self.reload_settings!
    STDOUT << "#{Time.zone.now.utc} - Clearing settings cache\n"
    Rails.cache.delete_matched('settings:.*')
    STDOUT << "#{Time.zone.now.utc} - Settings cache cleared\n"
  end


  # cannot do instance validation because CachedSetting use save!
  def self.params_errors(params)
    errors = {}
    # DS data allowed and Allow key data cannot be both true
    if !!params["key_data_allowed"] && params["key_data_allowed"] == params["ds_data_allowed"]
      msg = "#{I18n.t(:key_data_allowed)} and #{I18n.t(:ds_data_with_key_allowed)} cannot be both true"
      errors["key_data_allowed"] = msg
      errors["ds_data_allowed"]  = msg
    end

    return errors
  end

  def self.integer_settings
    %i[
      admin_contacts_min_count
      admin_contacts_max_count
      tech_contacts_min_count
      tech_contacts_max_count
      orphans_contacts_in_months
      ds_digest_type
      dnskeys_min_count
      dnskeys_max_count
      ns_min_count
      ns_max_count
      transfer_wait_time
      invoice_number_min
      invoice_number_max
      days_to_keep_business_registry_cache
      days_to_keep_invoices_active
      days_to_keep_overdue_invoices_active
      days_to_renew_domain_before_expire
      expire_warning_period
      redemption_grace_period
      expire_pending_confirmation
    ]
  end

  def self.float_settings
    %i[
      registry_vat_prc
      minimum_deposit
    ]
  end

  def self.boolean_settings
    %i[
      ds_data_allowed
      key_data_allowed
      client_side_status_editing_enabled
      registrar_ip_whitelist_enabled
      api_ip_whitelist_enabled
      request_confrimation_on_registrant_change_enabled
      request_confirmation_on_domain_deletion_enabled
      nameserver_required
      address_processing
    ]
  end
end
