class AddRegistrarsSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :registrars, :settings, :jsonb, null: false, default: '{}'
  end
end