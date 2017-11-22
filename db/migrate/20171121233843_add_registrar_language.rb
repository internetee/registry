class AddRegistrarLanguage < ActiveRecord::Migration
  def change
    add_column :registrars, :language, :string
  end
end
