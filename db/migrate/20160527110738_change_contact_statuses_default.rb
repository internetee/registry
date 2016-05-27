class ChangeContactStatusesDefault < ActiveRecord::Migration
  def change
    change_column_default :contacts, :statuses, []
  end
end
