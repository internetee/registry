class AddStatusesBackupForDomains < ActiveRecord::Migration[6.0]
  def change
    add_column :domains, :statuses_backup, :string, array: true, default: []
  end
end
