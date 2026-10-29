class AddPendingOperationAuthenticationIndex < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :pending_operation_events,
              "pending_operation_id, (identity->>'registrant_ident'), COALESCE(authenticated_at, 'infinity'::timestamp)",
              unique: true, where: "event = 'authenticated'", name: 'index_pending_operation_events_one_authentication',
              algorithm: :concurrently, if_not_exists: true
  end
end
