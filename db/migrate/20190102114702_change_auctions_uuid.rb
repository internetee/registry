class ChangeAuctionsUuid < ActiveRecord::Migration
  def change
    change_column :auctions, :uuid, :uuid, null: false, default: 'gen_random_uuid()'
  end
end
