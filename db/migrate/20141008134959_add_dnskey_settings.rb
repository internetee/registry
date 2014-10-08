class AddDnskeySettings < ActiveRecord::Migration
  def change
    sg = SettingGroup.create(code: 'dnskeys')
    sg.settings << Setting.create(code: 'ds_algorithm', value: 1)
    sg.settings << Setting.create(code: 'allow_ds_data', value: 1)
    sg.settings << Setting.create(code: 'allow_ds_data_with_keys', value: 1)
    sg.settings << Setting.create(code: 'allow_key_data', value: 1)
  end
end
