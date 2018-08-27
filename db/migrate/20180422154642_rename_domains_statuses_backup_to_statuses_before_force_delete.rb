class RenameDomainsStatusesBackupToStatusesBeforeForceDelete < ActiveRecord::Migration
  def change
    rename_column :domains, :statuses_backup, :statuses_before_force_delete
  end
end
