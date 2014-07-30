class AddPeriodToDomain < ActiveRecord::Migration
  def change
    add_column :domains, :period, :integer
  end
end
