class ChangeDisputeExpireTime < ActiveRecord::Migration
  def change
    change_column :disputes, :expire_time, :date
    rename_column :disputes, :expire_time, :expire_date
  end
end
