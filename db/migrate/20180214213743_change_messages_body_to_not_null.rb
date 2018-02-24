class ChangeMessagesBodyToNotNull < ActiveRecord::Migration
  def change
    change_column_null :messages, :body, false
  end
end
