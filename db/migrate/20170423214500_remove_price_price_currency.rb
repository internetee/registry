class RemovePricePriceCurrency < ActiveRecord::Migration[6.0]
  def change
    remove_column :prices, :price_currency, :string
  end
end
