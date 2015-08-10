class AddStatusesBackupForDomains < ActiveRecord::Migration
  def change
    add_column :domains, :statuses_backup, :string, array: true, default: []
  end
end
