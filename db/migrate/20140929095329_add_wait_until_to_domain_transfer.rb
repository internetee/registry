class AddWaitUntilToDomainTransfer < ActiveRecord::Migration[6.0]
  def change
    add_column :domain_transfers, :wait_until, :datetime
  end
end
