class ChangeMessagesBodyToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :messages, :body, false
  end
end
