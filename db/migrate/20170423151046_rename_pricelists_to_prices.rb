class RenamePricelistsToPrices < ActiveRecord::Migration
  def change
    rename_table :pricelists, :prices
  end
end
