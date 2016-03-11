class AddExcludeMonthlyDirectoToRegistrar < ActiveRecord::Migration
  def change
    add_column :registrars, :exclude_in_monthly_directo, :boolean, default: false
  end
end
