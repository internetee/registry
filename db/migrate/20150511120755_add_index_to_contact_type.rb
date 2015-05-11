class AddIndexToContactType < ActiveRecord::Migration
  def change
    add_index :contacts, [:registrar_id, :ident_type]
  end
end
