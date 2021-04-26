class AddLogPricelistIdToAccountActivity < ActiveRecord::Migration[6.0]
  def change
    add_column :account_activities, :log_pricelist_id, :integer
  end
end
