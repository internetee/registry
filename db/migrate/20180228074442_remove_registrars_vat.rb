class RemoveRegistrarsVat < ActiveRecord::Migration[6.0]
  def change
    remove_column :registrars, :vat, :boolean
  end
end
