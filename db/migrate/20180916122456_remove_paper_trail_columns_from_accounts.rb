class RemovePaperTrailColumnsFromAccounts < ActiveRecord::Migration
  def change
    remove_column :accounts, :creator_str
    remove_column :accounts, :updator_str
  end
end
