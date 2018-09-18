class DropLogAccountActivities < ActiveRecord::Migration
  def change
    drop_table :log_account_activities
  end
end
