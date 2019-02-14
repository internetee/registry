class RemoveAuctionableDomains < ActiveRecord::Migration
  def change
    drop_table :auctionable_domains
  end
end
