class AddDescriptionToAccountActivity < ActiveRecord::Migration[6.0]
  def change
    add_column :account_activities, :description, :string
  end
end
