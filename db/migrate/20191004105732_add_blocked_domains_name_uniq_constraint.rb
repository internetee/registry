class AddBlockedDomainsNameUniqConstraint < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE blocked_domains ADD CONSTRAINT uniq_blocked_domains_name UNIQUE (name);
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE blocked_domains DROP CONSTRAINT uniq_blocked_domains_name;
    SQL
  end
end
