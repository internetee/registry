class AddOrgNameToContact < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :org_name, :string
  end
end
