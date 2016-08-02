class ChangeContactStatusesDefault < ActiveRecord::Migration
  def change
    change_column_default :contacts, :statuses, []
    Contact.where(statuses: nil). update_all(statuses: [])
  end
end
