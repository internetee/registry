class AddDnskeySettings < ActiveRecord::Migration
  def change
    sg = SettingGroup.create(code: 'dnskeys')
    sg.settings << Setting.create(code: Setting::DS_ALGORITHM, value: 1)
    sg.settings << Setting.create(code: Setting::ALLOW_DS_DATA, value: 1)
    sg.settings << Setting.create(code: Setting::ALLOW_DS_DATA_WITH_KEYS, value: 1)
    sg.settings << Setting.create(code: Setting::ALLOW_KEY_DATA, value: 1)
  end
end
