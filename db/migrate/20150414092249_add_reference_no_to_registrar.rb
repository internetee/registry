class AddReferenceNoToRegistrar < ActiveRecord::Migration
  def change
    add_column :registrars, :reference_no, :string

    Registrar.all.each do |x|
      x.generate_iso_11649_reference_no
      x.save
    end
  end
end
