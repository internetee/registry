class AddAuditIndexesToLogReservedDomains < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :log_reserved_domains, :domain_name, algorithm: :concurrently
    add_index :log_reserved_domains, :source, algorithm: :concurrently
    add_index :log_reserved_domains, :reason, algorithm: :concurrently
    add_index :log_reserved_domains, :created_at, algorithm: :concurrently
  end
end
