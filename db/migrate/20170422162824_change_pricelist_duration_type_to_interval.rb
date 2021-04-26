class ChangePricelistDurationTypeToInterval < ActiveRecord::Migration[6.0]
  def change
    execute <<-SQL
      ALTER TABLE pricelists ALTER COLUMN duration TYPE interval USING (trim(duration)::interval)
    SQL
  end
end
