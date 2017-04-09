class ReorderDisputeColumns < ActiveRecord::Migration
  def change
    change_column :disputes, :domain_name, :string, null: false, after: :id
    change_column :disputes, :created_at, :datetime, after: :comment
  end
end
