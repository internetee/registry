class AddRegistrantIdentToUsers < ActiveRecord::Migration
  def change
    add_column :users, :registrant_ident, :string
  end
end
