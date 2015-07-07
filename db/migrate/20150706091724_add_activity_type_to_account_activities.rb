class AddActivityTypeToAccountActivities < ActiveRecord::Migration
  def change
    add_column :account_activities, :activity_type, :string
  end
end
