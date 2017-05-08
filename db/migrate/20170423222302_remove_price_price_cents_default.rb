class RemovePricePriceCentsDefault < ActiveRecord::Migration
  def change
    change_column_default :prices, :price_cents, nil
  end
end
