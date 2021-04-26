class ChangeAuctionsUuidDefault < ActiveRecord::Migration[6.0]
  def change
    change_column_default :auctions, :uuid, nil
  end
end
