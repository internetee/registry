class RemovePaperTrailColumnsFromAccountActivities < ActiveRecord::Migration
  def change
    remove_column :account_activities, :creator_str
    remove_column :account_activities, :updator_str
  end
end