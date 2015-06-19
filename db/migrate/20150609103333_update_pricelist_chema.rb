class UpdatePricelistChema < ActiveRecord::Migration
  def change
    add_column :pricelists, :operation_category, :string
    rename_column :pricelists, :name, :desc
  end
end
