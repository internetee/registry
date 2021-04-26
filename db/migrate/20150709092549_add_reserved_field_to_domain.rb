class AddReservedFieldToDomain < ActiveRecord::Migration[6.0]
  def change
    add_column :domains, :reserved, :boolean, default: false
  end
end
