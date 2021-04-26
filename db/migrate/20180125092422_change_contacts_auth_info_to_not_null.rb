class ChangeContactsAuthInfoToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :contacts, :auth_info, false
  end
end
