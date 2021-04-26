class AddTestRegistrarToRegistrar < ActiveRecord::Migration[6.0]
  def change
    add_column :registrars, :test_registrar, :boolean, default: false
  end
end
