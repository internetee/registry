class RemoveCachedNameservers < ActiveRecord::Migration[6.0]
  def change
    drop_table :cached_nameservers
  end
end
