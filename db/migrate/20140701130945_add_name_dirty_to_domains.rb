class AddNameDirtyToDomains < ActiveRecord::Migration[6.0]
  def change
    add_column :domains, :name_dirty, :string
    add_column :domains, :name_puny, :string
  end
end
