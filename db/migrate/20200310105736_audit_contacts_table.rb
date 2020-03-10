require 'audit_migration'

class AuditContactsTable < ActiveRecord::Migration[5.1]
  def up
    migration = AuditMigration.new('contact')
    execute(migration.create_table)
    execute(migration.create_trigger)
  end

  def down
    migration = AuditMigration.new('contact')
    execute(migration.drop)
  end
end
