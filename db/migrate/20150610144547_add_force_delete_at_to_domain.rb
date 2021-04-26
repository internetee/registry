class AddForceDeleteAtToDomain < ActiveRecord::Migration[6.0]
  def change
    add_column :domains, :force_delete_at, :datetime
  end
end
