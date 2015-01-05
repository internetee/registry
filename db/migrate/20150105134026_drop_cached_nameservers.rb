class DropCachedNameservers < ActiveRecord::Migration
  def change
    drop_table :cached_nameservers
  end
end
