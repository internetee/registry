class AddSystemDisclosedAttributesToContact < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :system_disclosed_attributes, :string, array: true, default: []
  end
end
