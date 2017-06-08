class AddAccountActivityAccountIdForeignKey < ActiveRecord::Migration
  def change
    change_column :account_activities, :account_id, :integer, null: false
    add_foreign_key :account_activities, :accounts
  end
end
