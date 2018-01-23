class RenameDomainTransfersTransferFromIdToOldRegistrarId < ActiveRecord::Migration
  def change
    rename_column :domain_transfers, :transfer_from_id, :old_registrar_id
  end
end
