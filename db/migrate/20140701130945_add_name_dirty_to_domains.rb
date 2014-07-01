class AddNameDirtyToDomains < ActiveRecord::Migration
  def change
    add_column :domains, :name_dirty, :string
    add_column :domains, :name_puny, :string
  end
end
