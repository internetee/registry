class AddAccessTokenToReservedDomains < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :reserved_domains, :access_token, :string
    add_column :reserved_domains, :token_created_at, :datetime
    add_index :reserved_domains, :access_token, unique: true, algorithm: :concurrently
  end
end
