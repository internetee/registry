class AddDomainTransfersTransferToIdFk < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :domain_transfers, :registrars, column: :transfer_to_id
  end
end
