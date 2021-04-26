class AddPostalInfoToAddress < ActiveRecord::Migration[6.0]
  def change
    add_column :addresses, :name, :string
    add_column :addresses, :org_name, :string
    add_column :addresses, :type, :string

    remove_column :contacts, :name, :string
    remove_column :contacts, :org_name, :string
  end
end
