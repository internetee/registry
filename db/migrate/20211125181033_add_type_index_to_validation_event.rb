class AddTypeIndexToValidationEvent < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :validation_events, :validation_eventable_id, :algorithm => :concurrently
  end
end
