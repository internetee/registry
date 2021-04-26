class AddPeriodUnitToDomain < ActiveRecord::Migration[6.0]
  def change
    add_column :domains, :period_unit, :char
  end
end
