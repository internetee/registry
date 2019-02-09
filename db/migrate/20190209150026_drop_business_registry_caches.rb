class DropBusinessRegistryCaches < ActiveRecord::Migration
  def change
    drop_table :business_registry_caches
  end
end