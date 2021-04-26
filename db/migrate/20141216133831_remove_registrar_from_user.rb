class RemoveRegistrarFromUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :registrar_id
  end
end
