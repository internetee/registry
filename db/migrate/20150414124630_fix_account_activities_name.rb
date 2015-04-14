class FixAccountActivitiesName < ActiveRecord::Migration
  def change
    rename_table :account_activites, :account_activities
  end
end
