class AddIdentToContact < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :ident, :string
  end
end
