class RemoveIncidentsFromBouncedMailAddresses < ActiveRecord::Migration[6.0]
  def up
    remove_column :bounced_mail_addresses, :incidents
  end

  def down
    add_column :bounced_mail_addresses, :incidents, :integer, null: false, default: 1
  end
end
