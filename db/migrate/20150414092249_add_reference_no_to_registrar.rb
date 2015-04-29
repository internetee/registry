class AddReferenceNoToRegistrar < ActiveRecord::Migration
  def change
    add_column :registrars, :reference_no, :string
  end
end
