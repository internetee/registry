class AddDomainTransfersTransferFromIdFk < ActiveRecord::Migration
  def change
    add_foreign_key :domain_transfers, :registrars, column: :transfer_from_id
  end
end
