class AddIdentityCodeIndex < ActiveRecord::Migration[6.0]
  def change
    add_index :users, :identity_code
  end
end
