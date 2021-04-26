class ChangeContactsEmailToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :contacts, :email, false
  end
end