class RemoveDepricatedVersions < ActiveRecord::Migration[6.0]
  def change
    drop_table :depricated_versions
  end
end
