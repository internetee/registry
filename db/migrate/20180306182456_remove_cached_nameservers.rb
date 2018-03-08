class RemoveCachedNameservers < ActiveRecord::Migration
  def change
    drop_table :cached_nameservers
  end
end
