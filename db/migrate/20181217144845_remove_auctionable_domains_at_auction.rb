class RemoveAuctionableDomainsAtAuction < ActiveRecord::Migration
  def change
    remove_column :auctionable_domains, :at_auction
  end
end
