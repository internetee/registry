class ChangePricePriceCentsTypeToInteger < ActiveRecord::Migration
  def change
    change_column :prices, :price_cents, 'integer USING CAST(price_cents AS integer)'
  end
end
