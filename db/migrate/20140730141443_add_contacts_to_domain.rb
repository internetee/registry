class AddContactsToDomain < ActiveRecord::Migration
  def change
    create_table :domain_contacts do |t|
      t.integer :contact_id
      t.integer :domain_id
      t.string :contact_type

      t.timestamps
    end
  end
end
