class AddStatusesToContact < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :statuses, :string, array: true
  end
end
