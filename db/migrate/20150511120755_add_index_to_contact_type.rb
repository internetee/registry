class AddIndexToContactType < ActiveRecord::Migration[6.0]
  def change
    add_index :contacts, [:registrar_id, :ident_type]
  end
end
