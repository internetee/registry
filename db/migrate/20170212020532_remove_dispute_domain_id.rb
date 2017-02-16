class RemoveDisputeDomainId < ActiveRecord::Migration
  def change
    remove_column :disputes, :domain_id
  end
end
