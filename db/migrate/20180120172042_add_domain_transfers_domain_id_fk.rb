class AddDomainTransfersDomainIdFk < ActiveRecord::Migration
  def change
    add_foreign_key :domain_transfers, :domains
  end
end
