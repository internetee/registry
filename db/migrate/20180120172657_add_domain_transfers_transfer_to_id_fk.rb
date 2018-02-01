class AddDomainTransfersTransferToIdFk < ActiveRecord::Migration
  def change
    add_foreign_key :domain_transfers, :registrars, column: :transfer_to_id
  end
end
