class AddPendingOperationEventIndexes < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :pending_operation_events, :pending_operation_id, algorithm: :concurrently, if_not_exists: true
    add_index :pending_operation_events, :pending_operation_id, unique: true,
              where: "event IN ('approved', 'denied', 'cancelled', 'expired')",
              name: 'index_pending_operation_events_one_terminal', algorithm: :concurrently, if_not_exists: true
  end
end
