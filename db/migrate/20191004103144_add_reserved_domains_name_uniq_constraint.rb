class AddReservedDomainsNameUniqConstraint < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE reserved_domains ADD CONSTRAINT uniq_reserved_domains_name UNIQUE (name);
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE reserved_domains DROP CONSTRAINT uniq_reserved_domains_name;
    SQL
  end
end
