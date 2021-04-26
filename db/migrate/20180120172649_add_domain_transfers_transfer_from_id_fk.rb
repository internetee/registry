class AddDomainTransfersTransferFromIdFk < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :domain_transfers, :registrars, column: :transfer_from_id
  end
end
