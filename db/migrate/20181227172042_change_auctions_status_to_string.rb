class ChangeAuctionsStatusToString < ActiveRecord::Migration[6.0]
  def change
    change_column :auctions, :status, :string

    execute <<-SQL
      DROP type auction_status;
    SQL
  end
end
