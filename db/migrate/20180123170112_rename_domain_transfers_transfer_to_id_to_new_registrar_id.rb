class RenameDomainTransfersTransferToIdToNewRegistrarId < ActiveRecord::Migration
  def change
    rename_column :domain_transfers, :transfer_to_id, :new_registrar_id
  end
end
