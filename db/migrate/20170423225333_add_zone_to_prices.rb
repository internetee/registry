class AddZoneToPrices < ActiveRecord::Migration
  def up
    add_reference :prices, :zone, index: true
    add_foreign_key :prices, :zones
    assign_zone_to_current_prices
    change_column :prices, :zone_id, :integer, null: false
    remove_column :prices, :category, :string
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def assign_zone_to_current_prices
    Billing::Price.all.each do |price|
      zone = DNS::Zone.find_by!(origin: price.category)
      price.zone = zone
      price.save!
    end
  end
end
