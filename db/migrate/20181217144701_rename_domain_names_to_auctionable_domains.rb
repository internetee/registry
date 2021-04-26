class RenameDomainNamesToAuctionableDomains < ActiveRecord::Migration[6.0]
  def change
    rename_table :domain_names, :auctionable_domains
  end
end
