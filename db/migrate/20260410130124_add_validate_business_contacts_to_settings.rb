class AddValidateBusinessContactsToSettings < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      INSERT INTO setting_entries (code, value, format, "group", created_at, updated_at)
      SELECT 'validate_business_contacts', 'true', 'boolean', 'contacts', NOW(), NOW()
      WHERE NOT EXISTS (SELECT 1 FROM setting_entries WHERE code = 'validate_business_contacts');
    SQL
  end

  def down
    execute "DELETE FROM setting_entries WHERE code = 'validate_business_contacts';"
  end
end
