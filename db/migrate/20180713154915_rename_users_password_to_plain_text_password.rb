class RenameUsersPasswordToPlainTextPassword < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :password, :plain_text_password
  end
end
