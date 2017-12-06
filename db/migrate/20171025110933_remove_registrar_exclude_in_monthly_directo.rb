class RemoveRegistrarExcludeInMonthlyDirecto < ActiveRecord::Migration
  def change
    remove_column :registrars, :exclude_in_monthly_directo, :string
  end
end
