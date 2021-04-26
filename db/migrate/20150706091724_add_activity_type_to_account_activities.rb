class AddActivityTypeToAccountActivities < ActiveRecord::Migration[6.0]
  def change
    add_column :account_activities, :activity_type, :string
  end
end
