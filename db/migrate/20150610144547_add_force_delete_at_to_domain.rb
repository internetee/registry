class AddForceDeleteAtToDomain < ActiveRecord::Migration
  def change
    add_column :domains, :force_delete_at, :datetime
  end
end
