class RemovePriceDesc < ActiveRecord::Migration
  def change
    remove_column :prices, :desc, :string
  end
end
