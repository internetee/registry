class ChangeContactsAuthInfoToNotNull < ActiveRecord::Migration
  def change
    change_column_null :contacts, :auth_info, false
  end
end
