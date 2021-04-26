class AddCopyFromId < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :copy_from_id, :integer
  end
end
