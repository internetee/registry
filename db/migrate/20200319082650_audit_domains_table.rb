require 'audit_migration'

class AuditDomainsTable < ActiveRecord::Migration[5.1]
  def up
    migration = AuditMigration.new('domain')
    execute(migration.create_table)
    execute(migration.create_trigger)
  end

  def down
    migration = AuditMigration.new('domain')
    execute(migration.drop)
  end
end
