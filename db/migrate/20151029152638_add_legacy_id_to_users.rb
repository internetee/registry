class AddLegacyIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :legacy_id, :integer
  end
end
