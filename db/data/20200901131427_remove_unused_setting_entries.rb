class RemoveUnusedSettingEntries < ActiveRecord::Migration[6.0]
  def up
    unused_fields = %w[eis_iban eis_bank eis_swift eis_invoice_contact ds_data_with_key_allowed]
    unused_fields.each do |stg|
      setting = SettingEntry.find_by(code: stg)
      next unless setting

      setting.destroy
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
