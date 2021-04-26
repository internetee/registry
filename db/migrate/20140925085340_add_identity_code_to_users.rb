class AddIdentityCodeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :identity_code, :string
  end
end
