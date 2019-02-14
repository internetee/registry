class RemoveAuctionsNotNullConstraints < ActiveRecord::Migration
  def change
    change_column_null :auctions, :uuid, true
  end
end
