class AddIndexToLogDomainObject < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!
  def up
    enable_extension 'btree_gin'
    add_index :log_domains, :object, using: :gin, algorithm: :concurrently, if_not_exists: true
  end

  def down
    remove_index :log_domains, :object
  end
end
