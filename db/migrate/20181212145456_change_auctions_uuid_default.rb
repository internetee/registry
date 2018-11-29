class ChangeAuctionsUuidDefault < ActiveRecord::Migration
  def change
    change_column_default :auctions, :uuid, nil
  end
end
