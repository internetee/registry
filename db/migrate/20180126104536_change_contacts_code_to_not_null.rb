class ChangeContactsCodeToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :contacts, :code, false
  end
end
