class ChangePriceToDecimal < ActiveRecord::Migration[6.0]
  def change
    change_column :pricelists, :price_cents, :decimal, precision: 8, scale: 2
  end
end
