class AddRegistrantIdentToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :registrant_ident, :string
    add_index :users, :registrant_ident
  end
end
