class AddUniqueIndexToZoneOrigin < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE zones ADD CONSTRAINT unique_zone_origin UNIQUE (origin)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE zones DROP CONSTRAINT unique_zone_origin
    SQL
  end
end
