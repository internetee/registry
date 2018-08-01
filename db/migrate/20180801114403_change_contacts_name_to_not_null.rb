class ChangeContactsNameToNotNull < ActiveRecord::Migration
  def change
    change_column_null :contacts, :name, false
  end
end