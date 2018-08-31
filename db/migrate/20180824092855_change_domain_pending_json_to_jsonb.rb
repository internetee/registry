class ChangeDomainPendingJsonToJsonb < ActiveRecord::Migration
  def up
    change_column :domains, :pending_json, 'jsonb USING CAST(pending_json AS jsonb)'
  end

  def down
    change_column :domains, :pending_json, 'json USING CAST(pending_json AS json)'
  end
end
