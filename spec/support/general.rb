module General
  def create_settings
    Setting.ds_algorithm = 2
    Setting.ds_data_allowed = true
    Setting.ds_data_with_key_allowed = true
    Setting.key_data_allowed = true

    Setting.dnskeys_min_count = 0
    Setting.dnskeys_max_count = 9
    Setting.ns_min_count = 2
    Setting.ns_max_count = 11

    Setting.transfer_wait_time = 0
  end

  def create_disclosure_settings
    Setting.disclosure_name = true
    Setting.disclosure_org_name = true
    Setting.disclosure_email = true
    Setting.disclosure_phone = false
    Setting.disclosure_fax = false
    Setting.disclosure_address = false
  end
end

RSpec.configure do |c|
  c.include General
end
