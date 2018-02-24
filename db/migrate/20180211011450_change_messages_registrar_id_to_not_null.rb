class ChangeMessagesRegistrarIdToNotNull < ActiveRecord::Migration
  def change
    change_column_null :messages, :registrar_id, false
  end
end
