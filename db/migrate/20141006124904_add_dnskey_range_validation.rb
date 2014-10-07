class AddDnskeyRangeValidation < ActiveRecord::Migration
  def change
    sg = SettingGroup.find_by(code: 'domain_validation')
    sg.settings << Setting.create(code: 'dnskeys_min_count'.underscore, value: '0')
    sg.settings << Setting.create(code: 'dnskeys_max_count'.underscore, value: '9')
  end
end
