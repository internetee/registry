RSpec.configure do |config|
  config.before :example do |example|
    if example.metadata[:db] && (example.metadata[:settings] != false)
      Fabricate(:zone, origin: 'com')

      Setting.ds_algorithm = 2
      Setting.ds_data_allowed = true
      Setting.ds_data_with_key_allowed = true
      Setting.key_data_allowed = true

      Setting.dnskeys_min_count = 0
      Setting.dnskeys_max_count = 9

      Setting.nameserver_required = false
      Setting.ns_min_count = 2
      Setting.ns_max_count = 11

      Setting.transfer_wait_time = 0

      Setting.admin_contacts_min_count = 1
      Setting.admin_contacts_max_count = 10
      Setting.tech_contacts_min_count = 0
      Setting.tech_contacts_max_count = 10

      Setting.client_side_status_editing_enabled = true
    end
  end
end
