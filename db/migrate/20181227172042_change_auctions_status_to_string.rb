class ChangeAuctionsStatusToString < ActiveRecord::Migration
  def change
    change_column :auctions, :status, :string

    execute <<-SQL
      DROP type auction_status;
    SQL
  end
end
