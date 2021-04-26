class RemoveAuctionableDomains < ActiveRecord::Migration[6.0]
  def change
    drop_table :auctionable_domains
  end
end
