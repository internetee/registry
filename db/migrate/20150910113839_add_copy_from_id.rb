class AddCopyFromId < ActiveRecord::Migration
  def change
    add_column :contacts, :copy_from_id, :integer
  end
end
