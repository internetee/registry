class ChangeActionsOperationToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :actions, :operation, false
  end
end
