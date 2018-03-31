class RemoveRegistrarsIndexes < ActiveRecord::Migration
  def change
    remove_index :registrars, name: :index_registrars_on_code
    remove_index :registrars, name: :index_registrars_on_legacy_id
  end
end
