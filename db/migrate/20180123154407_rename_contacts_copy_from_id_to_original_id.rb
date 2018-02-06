class RenameContactsCopyFromIdToOriginalId < ActiveRecord::Migration
  def change
    rename_column :contacts, :copy_from_id, :original_id
  end
end
