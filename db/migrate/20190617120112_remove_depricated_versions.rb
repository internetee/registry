class RemoveDepricatedVersions < ActiveRecord::Migration
  def change
    drop_table :depricated_versions
  end
end
