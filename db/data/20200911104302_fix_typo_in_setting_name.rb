class FixTypoInSettingName < ActiveRecord::Migration[6.0]
  def up
    setting = Setting.find_by(code: 'request_confrimation_on_registrant_change_enabled')
    setting.update(code: 'request_confirmation_on_registrant_change_enabled')
  end

  def down
    setting = Setting.find_by(code: 'request_confirmation_on_registrant_change_enabled')
    setting.update(code: 'request_confrimation_on_registrant_change_enabled')
  end
end
