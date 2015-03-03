class AddCodeToRegistrar < ActiveRecord::Migration
  def change
    add_column :registrars, :code, :string
    add_index :registrars, :code
  end
end
