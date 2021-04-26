class AddReferenceNoToRegistrar < ActiveRecord::Migration[6.0]
  def change
    add_column :registrars, :reference_no, :string
  end
end
