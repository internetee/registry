class AddDomainTransfersDomainIdFk < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :domain_transfers, :domains
  end
end
