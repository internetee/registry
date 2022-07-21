class RenameDomainsStatusesBackupToStatusesBeforeForceDelete < ActiveRecord::Migration[6.0]
  def change
    # rename_column :domains, :statuses_backup, :statuses_before_force_delete
  end
end
