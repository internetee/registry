class AddIdentToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :ident, :string
  end
end
