class AddAccountRegistrarFk < ActiveRecord::Migration
  def change
    change_column :accounts, :registrar_id, :integer, null: false
    add_foreign_key :accounts, :registrars
  end
end
