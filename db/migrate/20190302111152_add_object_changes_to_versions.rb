class AddObjectChangesToVersions < ActiveRecord::Migration[6.0]
  def change
    add_column :versions, :object_changes, :jsonb
  end
end
