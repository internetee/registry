class ChangePricelistDurationTypeToInterval < ActiveRecord::Migration
  def change
    execute <<-SQL
      ALTER TABLE pricelists ALTER COLUMN duration TYPE interval USING (trim(duration)::interval)
    SQL
  end
end
