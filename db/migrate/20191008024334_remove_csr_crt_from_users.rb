class RemoveCsrCrtFromUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :csr, :text
    remove_column :users, :crt, :text
  end
end