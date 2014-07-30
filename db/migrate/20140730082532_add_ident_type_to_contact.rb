class AddIdentTypeToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :ident_type, :string
  end
end
