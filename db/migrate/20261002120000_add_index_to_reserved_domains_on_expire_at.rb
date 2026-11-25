class AddIndexToReservedDomainsOnExpireAt < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :reserved_domains, :expire_at, algorithm: :concurrently
  end
end
