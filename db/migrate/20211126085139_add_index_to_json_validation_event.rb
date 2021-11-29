class AddIndexToJsonValidationEvent < ActiveRecord::Migration[6.1]
  def change
    add_index :validation_events, :event_data, :using => :gin
  end
end
