class ChangePriceToDecimal < ActiveRecord::Migration
  def change
    change_column :pricelists, :price_cents, :decimal, precision: 8, scale: 2
  end
end
