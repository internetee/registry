class AddLegacyColumnsForContact < ActiveRecord::Migration
  def change
    add_column :contacts, :legacy_id, :integer
    remove_column :contacts, :type, :string
    remove_column :contacts, :reg_no, :string
    remove_column :contacts, :created_by_id, :integer
    remove_column :contacts, :updated_by_id, :integer
  end
end
