class AddOrgNameToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :org_name, :string
  end
end
