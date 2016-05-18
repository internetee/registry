class AddTestRegistrarToRegistrar < ActiveRecord::Migration
  def change
    add_column :registrars, :test_registrar, :boolean, default: false
  end
end
