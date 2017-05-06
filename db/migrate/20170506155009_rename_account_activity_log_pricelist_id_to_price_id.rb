class RenameAccountActivityLogPricelistIdToPriceId < ActiveRecord::Migration
  def change
    rename_column :account_activities, :log_pricelist_id, :price_id
    add_foreign_key :account_activities, :prices
  end
end
