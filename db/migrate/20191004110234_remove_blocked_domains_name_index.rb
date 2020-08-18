class RemoveBlockedDomainsNameIndex < ActiveRecord::Migration
  def change
    remove_index :blocked_domains, name: 'index_blocked_domains_on_name'
  end
end
