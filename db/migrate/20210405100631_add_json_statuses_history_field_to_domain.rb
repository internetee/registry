class AddJsonStatusesHistoryFieldToDomain < ActiveRecord::Migration[6.0]
  def change
    add_column :domains, :json_statuses_history, :jsonb
    add_index :domains, :json_statuses_history, using: :gin
  end
end
