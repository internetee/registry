class RemovePricePriceCurrency < ActiveRecord::Migration
  def change
    remove_column :prices, :price_currency, :string
  end
end
