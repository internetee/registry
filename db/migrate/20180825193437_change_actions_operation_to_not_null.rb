class ChangeActionsOperationToNotNull < ActiveRecord::Migration
  def change
    change_column_null :actions, :operation, false
  end
end
