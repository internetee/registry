class ChangeMessagesRegistrarIdToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :messages, :registrar_id, false
  end
end
