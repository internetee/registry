class AddStatusesToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :statuses, :string, array: true
  end
end
