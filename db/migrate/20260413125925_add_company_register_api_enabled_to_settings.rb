class AddCompanyRegisterApiEnabledToSettings < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      execute <<~SQL
        INSERT INTO setting_entries (code, value, format, "group", created_at, updated_at)
        SELECT 'company_register_api_enabled', 'true', 'boolean', 'contacts', NOW(), NOW()
        WHERE NOT EXISTS (SELECT 1 FROM setting_entries WHERE code = 'company_register_api_enabled');
      SQL
    end
  end

  def down
    safety_assured do
      execute "DELETE FROM setting_entries WHERE code = 'company_register_api_enabled';"
    end
  end
end
