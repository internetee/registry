class RenameUsersPasswordToPlainTextPassword < ActiveRecord::Migration
  def change
    rename_column :users, :password, :plain_text_password
  end
end
