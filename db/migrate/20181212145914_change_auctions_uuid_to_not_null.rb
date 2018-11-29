class ChangeAuctionsUuidToNotNull < ActiveRecord::Migration
  def change
    change_column_null :auctions, :uuid, false
  end
end
