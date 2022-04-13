class AddTypeToAuction < ActiveRecord::Migration[6.1]
  def change
    add_column :auctions, :platform, :integer, null: true
  end
end
