class AddLegacyIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :legacy_id, :integer
  end
end
