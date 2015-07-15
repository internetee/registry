class IncreasePrecisionOfPricelist < ActiveRecord::Migration
  def change
    change_column :pricelists, :price_cents, :decimal, precision: 10, scale: 2
  end
end
