class RemoveDefaultsFromDisclosure < ActiveRecord::Migration
  def change
    change_column :contact_disclosures, :phone, :boolean, :default => nil
    change_column :contact_disclosures, :fax, :boolean, :default => nil
    change_column :contact_disclosures, :email, :boolean, :default => nil
  end
end
