class RemoveAddressTypeFromContactDisclosure < ActiveRecord::Migration
  def change
    remove_column :contact_disclosures, :int_name, :boolean
    remove_column :contact_disclosures, :int_org_name, :boolean
    remove_column :contact_disclosures, :int_addr, :boolean
    remove_column :contact_disclosures, :loc_name, :boolean
    remove_column :contact_disclosures, :loc_org_name, :boolean
    remove_column :contact_disclosures, :loc_addr, :boolean

    add_column :contact_disclosures, :name, :boolean
    add_column :contact_disclosures, :org_name, :boolean
    add_column :contact_disclosures, :address, :boolean
  end
end
