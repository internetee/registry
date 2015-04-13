class AddIdentityCodeIndex < ActiveRecord::Migration
  def change
    add_index :users, :identity_code
  end
end
