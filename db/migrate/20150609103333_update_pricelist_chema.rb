class UpdatePricelistChema < ActiveRecord::Migration[6.0]
  def change
    add_column :pricelists, :operation_category, :string
    rename_column :pricelists, :name, :desc
  end
end
