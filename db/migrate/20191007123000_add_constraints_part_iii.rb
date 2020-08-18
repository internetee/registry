class AddConstraintsPartIii < ActiveRecord::Migration
  def change
    change_column_null :domains, :name, false
    change_column_null :domains, :name_puny, false
    change_column_null :domains, :name_dirty, false
  end
end
