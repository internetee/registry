class AddRegistrarsVatRate < ActiveRecord::Migration
  def change
    add_column :registrars, :vat_rate, :decimal, precision: 4, scale: 3
  end
end
