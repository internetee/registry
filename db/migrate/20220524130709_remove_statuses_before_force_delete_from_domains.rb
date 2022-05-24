class RemoveStatusesBeforeForceDeleteFromDomains < ActiveRecord::Migration[6.1]
  def change
    remove_column :domains, :statuses_before_force_delete
  end
end
