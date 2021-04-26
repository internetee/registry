class RemoveDataMigrations < ActiveRecord::Migration[6.0]
  def change
    drop_table :data_migrations
  end
end
