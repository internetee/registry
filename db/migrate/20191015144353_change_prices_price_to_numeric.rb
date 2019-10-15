class ChangePricesPriceToNumeric < ActiveRecord::Migration
  def change
    change_column :prices, :price_cents, 'numeric(10,2) USING price_cents / 100'
    rename_column :prices, :price_cents, :price
  end
end
