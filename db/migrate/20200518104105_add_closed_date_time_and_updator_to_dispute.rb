class AddClosedDateTimeAndUpdatorToDispute < ActiveRecord::Migration[5.2]
  def up
    rename_column :disputes, :closed, :closed_boolean
    add_column :disputes, :closed, :datetime
    execute 'UPDATE disputes SET closed = updated_at WHERE closed_boolean = true'
    execute 'UPDATE disputes SET closed = NULL WHERE closed_boolean = false'
    remove_column :disputes, :closed_boolean
    add_column :disputes, :initiator, :string
  end

  def down
    rename_column :disputes, :closed, :closed_datetime
    add_column :disputes, :closed, :boolean, null: false, default: false
    execute 'UPDATE disputes SET closed = true WHERE closed_datetime != NULL'
    execute 'UPDATE disputes SET closed = false WHERE closed_datetime = NULL'
    remove_column :disputes, :closed_datetime
    remove_column :disputes, :initiator
  end
end
