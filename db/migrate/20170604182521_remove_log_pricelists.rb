class RemoveLogPricelists < ActiveRecord::Migration[6.0]
  def change
    drop_table :log_pricelists
  end
end
