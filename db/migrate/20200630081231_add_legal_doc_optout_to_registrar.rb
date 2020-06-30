class AddLegalDocOptoutToRegistrar < ActiveRecord::Migration[6.0]
  def change
    add_column :registrars, :legaldoc_optout, :boolean, null: false, default: false
  end
end
