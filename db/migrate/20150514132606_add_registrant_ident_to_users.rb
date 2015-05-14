class AddRegistrantIdentToUsers < ActiveRecord::Migration
  def change
    add_column :users, :registrant_ident, :string
    add_index :users, :registrant_ident
  end
end
