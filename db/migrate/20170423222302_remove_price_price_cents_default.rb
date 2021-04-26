class RemovePricePriceCentsDefault < ActiveRecord::Migration[6.0]
  def change
    change_column_default :prices, :price_cents, nil
  end
end
