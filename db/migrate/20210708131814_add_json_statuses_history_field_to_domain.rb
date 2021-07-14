class AddJsonStatusesHistoryFieldToDomain < ActiveRecord::Migration[6.1]
  def change
		add_column :domains, :json_statuses_history, :jsonb, if_not_exists: true
    add_index :domains, :json_statuses_history, using: :gin, if_not_exists: true
  end
end
