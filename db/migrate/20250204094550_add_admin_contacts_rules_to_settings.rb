class AddAdminContactsRulesToSettings < ActiveRecord::Migration[6.1]
  def up
    unless SettingEntry.exists?(code: 'admin_contacts_required_for_org')
      SettingEntry.create!(
        code: 'admin_contacts_required_for_org',
        value: 'true',
        format: 'boolean',
        group: 'domain_validation'
      )
    else
      puts "SettingEntry admin_contacts_required_for_org already exists"
    end

    unless SettingEntry.exists?(code: 'admin_contacts_required_for_minors')
      SettingEntry.create!(
        code: 'admin_contacts_required_for_minors',
        value: 'true',
        format: 'boolean',
        group: 'domain_validation'
      )
    else
      puts "SettingEntry admin_contacts_required_for_minors already exists"
    end

    unless SettingEntry.exists?(code: 'admin_contacts_allowed_ident_type')
      SettingEntry.create!(
        code: 'admin_contacts_allowed_ident_type',
        value: {
          'birthday' => true,
          'priv' => true,
          'org' => false
        }.to_json,
        format: 'array',
        group: 'domain_validation'
      )
    else
      puts "SettingEntry admin_contacts_allowed_ident_type already exists"
    end
  end

  def down
    SettingEntry.where(code: [
      'admin_contacts_required_for_org',
      'admin_contacts_required_for_minors',
      'admin_contacts_allowed_ident_type'
    ]).destroy_all
  end
end
