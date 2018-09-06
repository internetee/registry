class AddRegistrarsSettings < ActiveRecord::Migration
  def change
    add_column :registrars, :settings, :jsonb, null: false, default: '{}'
  end
end