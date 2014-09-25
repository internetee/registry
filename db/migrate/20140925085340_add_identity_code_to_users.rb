class AddIdentityCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :identity_code, :string
  end
end
