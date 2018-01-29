class ChangeContactsCodeToNotNull < ActiveRecord::Migration
  def change
    change_column_null :contacts, :code, false
  end
end
