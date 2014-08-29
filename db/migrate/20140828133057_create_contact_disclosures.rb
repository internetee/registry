class CreateContactDisclosures < ActiveRecord::Migration
  def change
    create_table :contact_disclosures do |t|
      t.integer :contact_id

      t.boolean :int_name, default: false
      t.boolean :int_org_name, default: false
      t.boolean :int_addr, default: false
      t.boolean :loc_name, default: false
      t.boolean :loc_org_name, default: false
      t.boolean :loc_addr, default: false
      t.boolean :phone, default: false
      t.boolean :fax, default: false
      t.boolean :email, default: false

      t.timestamps
    end
  end
end
