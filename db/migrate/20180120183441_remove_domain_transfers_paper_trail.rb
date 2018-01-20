class RemoveDomainTransfersPaperTrail < ActiveRecord::Migration
  def change
    remove_column :domain_transfers, :creator_str, :string
    remove_column :domain_transfers, :updator_str, :string
  end
end
