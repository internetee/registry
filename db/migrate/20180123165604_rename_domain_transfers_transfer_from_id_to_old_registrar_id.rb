class RenameDomainTransfersTransferFromIdToOldRegistrarId < ActiveRecord::Migration[6.0]
  def change
    rename_column :domain_transfers, :transfer_from_id, :old_registrar_id
  end
end
