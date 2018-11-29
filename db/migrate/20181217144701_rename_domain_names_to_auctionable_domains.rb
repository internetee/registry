class RenameDomainNamesToAuctionableDomains < ActiveRecord::Migration
  def change
    rename_table :domain_names, :auctionable_domains
  end
end
