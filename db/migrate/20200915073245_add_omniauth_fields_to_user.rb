class AddOmniauthFieldsToUser < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_index :users, [:provider, :uid], algorithm: :concurrently,
              unique: true
  end
end
