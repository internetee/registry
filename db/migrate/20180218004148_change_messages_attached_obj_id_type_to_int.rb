class ChangeMessagesAttachedObjIdTypeToInt < ActiveRecord::Migration[6.0]
  def change
    change_column :messages, :attached_obj_id, 'integer USING attached_obj_id::integer'
  end
end
