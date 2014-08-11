class AddPeriodUnitToDomain < ActiveRecord::Migration
  def change
    add_column :domains, :period_unit, :char
  end
end
