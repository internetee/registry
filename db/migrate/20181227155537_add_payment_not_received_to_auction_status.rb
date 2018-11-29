class AddPaymentNotReceivedToAuctionStatus < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    execute <<-SQL
      ALTER TYPE auction_status ADD VALUE 'payment_not_received' AFTER 'payment_received';
    SQL
  end
end
