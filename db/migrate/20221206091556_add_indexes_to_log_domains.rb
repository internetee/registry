class AddIndexesToLogDomains < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!
  def up
    enable_extension 'btree_gin'
    add_index :log_domains, :event, algorithm: :concurrently
    add_index :log_domains, :object, using: :gin, algorithm: :concurrently
    add_index :log_domains, :object_changes, using: :gin, algorithm: :concurrently
  end

  def down
    remove_index :log_domains, :event
    remove_index :log_domains, :object
    remove_index :log_domains, :object_changes
  end
end
