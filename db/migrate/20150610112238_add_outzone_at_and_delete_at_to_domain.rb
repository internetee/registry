class AddOutzoneAtAndDeleteAtToDomain < ActiveRecord::Migration
  def change
    add_column :domains, :outzone_at, :datetime unless column_exists?(:domains, :outzone_at)
    add_column :domains, :delete_at, :datetime unless column_exists?(:domains, :delete_at)
  end
end
