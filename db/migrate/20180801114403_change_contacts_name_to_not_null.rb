class ChangeContactsNameToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :contacts, :name, false
  end
end