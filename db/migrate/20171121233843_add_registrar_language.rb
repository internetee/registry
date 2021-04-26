class AddRegistrarLanguage < ActiveRecord::Migration[6.0]
  def change
    add_column :registrars, :language, :string
  end
end
