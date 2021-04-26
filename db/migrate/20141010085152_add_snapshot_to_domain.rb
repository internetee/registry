class AddSnapshotToDomain < ActiveRecord::Migration[6.0]
  def change
    add_column :domain_versions, :snapshot, :text
  end
end
