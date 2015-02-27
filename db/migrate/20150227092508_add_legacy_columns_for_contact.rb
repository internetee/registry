class AddLegacyColumnsForContact < ActiveRecord::Migration
  def change
    add_column :contacts, :legacy_id, :integer
  end
end
