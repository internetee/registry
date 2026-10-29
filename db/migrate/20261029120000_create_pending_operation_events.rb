class CreatePendingOperationEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :pending_operation_events do |t|
      t.uuid :pending_operation_id, null: false
      t.bigint :domain_id
      t.string :domain_name
      t.string :operation
      t.string :event, null: false
      t.datetime :occurred_at, null: false
      t.string :actor_type
      t.string :actor_id
      t.string :actor_name
      t.string :recipient_email
      t.jsonb :identity
      t.datetime :authenticated_at
      t.datetime :created_at, null: false
    end
  end
end
