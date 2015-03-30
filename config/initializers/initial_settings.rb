# otherwise rake not working 100%
begin
  con = ActiveRecord::Base.connection
rescue ActiveRecord::NoDatabaseError => e
  Rails.logger.info "Init settings didn't find database: #{e}"
end

if con.present? && con.table_exists?('settings')
  Setting.disclosure_name = true if Setting.disclosure_name.nil?
  Setting.disclosure_name = true if Setting.disclosure_name.nil?
  Setting.disclosure_org_name = true if Setting.disclosure_org_name.nil?
  Setting.disclosure_email = true if Setting.disclosure_email.nil?
  Setting.disclosure_phone = false if Setting.disclosure_phone.nil?
  Setting.disclosure_fax = false if Setting.disclosure_fax.nil?
  Setting.disclosure_address = false if Setting.disclosure_address.nil?

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
end

# dev only setting
EPP_LOG_ENABLED = true # !Rails.env.test?
