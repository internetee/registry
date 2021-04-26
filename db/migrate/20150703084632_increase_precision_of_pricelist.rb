class IncreasePrecisionOfPricelist < ActiveRecord::Migration[6.0]
  def change
    change_column :pricelists, :price_cents, :decimal, precision: 10, scale: 2
  end
end
