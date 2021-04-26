class DropBusinessRegistryCaches < ActiveRecord::Migration[6.0]
  def change
    drop_table :business_registry_caches
  end
end