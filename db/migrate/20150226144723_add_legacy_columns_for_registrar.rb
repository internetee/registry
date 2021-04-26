class AddLegacyColumnsForRegistrar < ActiveRecord::Migration[6.0]
  def change
    add_column :registrars, :url, :string
    add_column :registrars, :directo_handle, :string
    add_column :registrars, :vat, :boolean
    add_column :registrars, :legacy_id, :integer
  end
end
