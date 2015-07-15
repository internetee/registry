class AddLogPricelistIdToAccountActivity < ActiveRecord::Migration
  def change
    add_column :account_activities, :log_pricelist_id, :integer
  end
end
