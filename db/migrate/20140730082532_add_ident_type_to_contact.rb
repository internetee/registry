class AddIdentTypeToContact < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :ident_type, :string
  end
end
