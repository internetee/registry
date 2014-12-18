class RemoveRegistrarFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :registrar_id
  end
end
