class CreateBusinessRegistryContacts < ActiveRecord::Migration[6.1]
  def change
    create_table :business_registry_contacts do |t|
      t.string :name
      t.string :registry_code
      t.string :status

      t.timestamps
    end
  end
end
