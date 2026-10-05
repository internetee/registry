class AddAuditColumnsToLogReservedDomains < ActiveRecord::Migration[6.1]
  def change
    add_column :log_reserved_domains, :source, :string
    add_column :log_reserved_domains, :reason, :string
    add_column :log_reserved_domains, :reason_note, :text
    add_column :log_reserved_domains, :domain_name, :string
    add_column :log_reserved_domains, :registrar_id, :integer
  end
end
