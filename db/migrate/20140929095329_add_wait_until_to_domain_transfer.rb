class AddWaitUntilToDomainTransfer < ActiveRecord::Migration
  def change
    add_column :domain_transfers, :wait_until, :datetime
  end
end
