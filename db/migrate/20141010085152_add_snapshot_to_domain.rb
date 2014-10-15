class AddSnapshotToDomain < ActiveRecord::Migration
  def change
    add_column :domain_versions, :snapshot, :text
  end
end
