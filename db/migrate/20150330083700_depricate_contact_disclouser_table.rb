class DepricateContactDisclouserTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :contact_disclosures
    drop_table :log_contact_disclosures
  end
end
