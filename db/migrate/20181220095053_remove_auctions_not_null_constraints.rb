class RemoveAuctionsNotNullConstraints < ActiveRecord::Migration[6.0]
  def change
    change_column_null :auctions, :uuid, true
  end
end
