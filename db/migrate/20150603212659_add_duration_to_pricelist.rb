class AddDurationToPricelist < ActiveRecord::Migration
  def change
    add_column :pricelists, :duration, :string
  end
end
