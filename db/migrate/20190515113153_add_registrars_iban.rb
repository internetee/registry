class AddRegistrarsIban < ActiveRecord::Migration[6.0]
  def change
    add_column :registrars, :iban, :string
  end
end
