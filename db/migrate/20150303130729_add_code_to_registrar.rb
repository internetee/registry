class AddCodeToRegistrar < ActiveRecord::Migration[6.0]
  def change
    add_column :registrars, :code, :string
    add_index :registrars, :code
  end
end
