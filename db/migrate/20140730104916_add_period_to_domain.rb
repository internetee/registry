class AddPeriodToDomain < ActiveRecord::Migration[6.0]
  def change
    add_column :domains, :period, :integer
  end
end
