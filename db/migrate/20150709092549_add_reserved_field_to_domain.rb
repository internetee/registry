class AddReservedFieldToDomain < ActiveRecord::Migration
  def change
    add_column :domains, :reserved, :boolean, default: false
  end
end
