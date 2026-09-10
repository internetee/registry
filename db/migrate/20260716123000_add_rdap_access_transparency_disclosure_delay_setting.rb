class AddRdapAccessTransparencyDisclosureDelaySetting < ActiveRecord::Migration[6.1]
  def up
    unless SettingEntry.exists?(code: 'rdap_access_transparency_disclosure_delay')
      SettingEntry.create!(
        code: 'rdap_access_transparency_disclosure_delay',
        value: '5',
        format: 'integer',
        group: 'rdap'
      )
    else
      puts "SettingEntry rdap_access_transparency_disclosure_delay already exists"
    end
  end

  def down
    SettingEntry.where(code: 'rdap_access_transparency_disclosure_delay').destroy_all
  end
end
