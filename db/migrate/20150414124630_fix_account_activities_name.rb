class FixAccountActivitiesName < ActiveRecord::Migration[6.0]
  def change
    rename_table :account_activites, :account_activities
  end
end
