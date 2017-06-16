class RemoveLogPricelists < ActiveRecord::Migration
  def change
    drop_table :log_pricelists
  end
end
