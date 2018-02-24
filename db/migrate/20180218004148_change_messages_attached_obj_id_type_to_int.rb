class ChangeMessagesAttachedObjIdTypeToInt < ActiveRecord::Migration
  def change
    change_column :messages, :attached_obj_id, 'integer USING attached_obj_id::integer'
  end
end
