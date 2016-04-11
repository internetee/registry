class AddUpIdValueToDomain < ActiveRecord::Migration
  def change
    add_column :domains, :upid, :integer
  end
end
