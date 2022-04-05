class AddBulkActions < ActiveRecord::Migration[6.1]
  def change
    add_column :actions, :bulk_action_id, :integer, default: nil
  end
end
