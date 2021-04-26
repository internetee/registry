class ChangeAuctionsUuidToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :auctions, :uuid, false
  end
end
