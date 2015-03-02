class AddLegacyColumnsForAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :legacy_contact_id, :integer
  end
end
