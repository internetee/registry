class AddVerificationFieldsToUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :users, :ident_request_sent_at, :datetime
    add_column :users, :verified_at, :datetime
    add_column :users, :verification_id, :string
    add_column :users, :verification_pending_at, :datetime
    add_column :users, :verification_snapshot, :jsonb, default: {}
    add_index :users, :verified_at, algorithm: :concurrently
    add_index :users, :verification_pending_at, algorithm: :concurrently
  end
end
