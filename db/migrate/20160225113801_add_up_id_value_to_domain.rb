class AddUpIdValueToDomain < ActiveRecord::Migration[6.0]
  def change
    add_column :domains, :upid, :integer
  end
end
