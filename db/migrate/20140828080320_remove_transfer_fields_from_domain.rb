class RemoveTransferFieldsFromDomain < ActiveRecord::Migration
  def change
    remove_column :domains, :transferred_at
    remove_column :domains, :transfer_requested_at
    remove_column :domains, :transfer_to
  end
end
