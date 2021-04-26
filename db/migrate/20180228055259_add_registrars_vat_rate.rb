class AddRegistrarsVatRate < ActiveRecord::Migration[6.0]
  def change
    add_column :registrars, :vat_rate, :decimal, precision: 4, scale: 3
  end
end
