class AddUpIdValueToDomain < ActiveRecord::Migration
  def change
    add_column :domains, :upid, :string
  end
end
