class CreateBusinessRegistryCaches < ActiveRecord::Migration
  def change
    create_table :business_registry_caches do |t|
      t.string   :ident
      t.string   :ident_country_code
      t.datetime :retrieved_on
      t.string   :associated_businesses, array: true
      t.timestamps null: false
    end

    add_index :business_registry_caches, :ident
  end
end
