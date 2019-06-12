class AddRegistrarsIban < ActiveRecord::Migration
  def change
    add_column :registrars, :iban, :string
  end
end
