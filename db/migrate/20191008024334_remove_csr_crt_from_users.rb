class RemoveCsrCrtFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :csr, :text
    remove_column :users, :crt, :text
  end
end