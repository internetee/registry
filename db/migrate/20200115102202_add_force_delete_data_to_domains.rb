class AddForceDeleteDataToDomains < ActiveRecord::Migration[5.0]
  def change
    add_column :domains, :force_delete_data, :hstore
  end
end
