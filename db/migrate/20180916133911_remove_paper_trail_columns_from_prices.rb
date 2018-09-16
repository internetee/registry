class RemovePaperTrailColumnsFromPrices < ActiveRecord::Migration
  def change
    remove_column :prices, :creator_str
    remove_column :prices, :updator_str
  end
end
