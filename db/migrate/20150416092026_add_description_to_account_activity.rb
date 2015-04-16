class AddDescriptionToAccountActivity < ActiveRecord::Migration
  def change
    add_column :account_activities, :description, :string
  end
end
