class RemoveDataMigrations < ActiveRecord::Migration
  def change
    drop_table :data_migrations
  end
end
