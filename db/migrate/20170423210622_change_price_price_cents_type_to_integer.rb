class ChangePricePriceCentsTypeToInteger < ActiveRecord::Migration[6.0]
  def change
    change_column :prices, :price_cents, 'integer USING CAST(price_cents AS integer)'
  end
end
