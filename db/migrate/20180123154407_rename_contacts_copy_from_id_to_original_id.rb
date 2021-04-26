class RenameContactsCopyFromIdToOriginalId < ActiveRecord::Migration[6.0]
  def change
    rename_column :contacts, :copy_from_id, :original_id
  end
end
