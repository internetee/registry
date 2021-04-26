class ChangeContactStatusesDefault < ActiveRecord::Migration[6.0]
  def change
    change_column_default :contacts, :statuses, []
    Contact.where(statuses: nil). update_all(statuses: [])
  end
end
