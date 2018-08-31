class ChangeContactsEmailToNotNull < ActiveRecord::Migration
  def change
    change_column_null :contacts, :email, false
  end
end