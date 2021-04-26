class RemoveAuctionableDomainsAtAuction < ActiveRecord::Migration[6.0]
  def change
    remove_column :auctionable_domains, :at_auction
  end
end
