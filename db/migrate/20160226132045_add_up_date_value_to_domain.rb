class AddUpDateValueToDomain < ActiveRecord::Migration
  def change
    add_column :domains, :update, :timestamp
  end
end
