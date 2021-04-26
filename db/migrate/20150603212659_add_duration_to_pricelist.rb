class AddDurationToPricelist < ActiveRecord::Migration[6.0]
  def change
    add_column :pricelists, :duration, :string
  end
end
