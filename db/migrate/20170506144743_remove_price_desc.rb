class RemovePriceDesc < ActiveRecord::Migration[6.0]
  def change
    remove_column :prices, :desc, :string
  end
end
