class RemoveBlockedDomainsNameIndex < ActiveRecord::Migration[6.0]
  def change
    remove_index :blocked_domains, name: 'index_blocked_domains_on_name'
  end
end
