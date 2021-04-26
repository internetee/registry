class RenameDomainTransfersTransferToIdToNewRegistrarId < ActiveRecord::Migration[6.0]
  def change
    rename_column :domain_transfers, :transfer_to_id, :new_registrar_id
  end
end
