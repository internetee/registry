require 'audit_migration'

class AuditRegistrarTable < ActiveRecord::Migration[5.1]
  def up
    migration = AuditMigration.new('registrar')
    execute(migration.create_table)
    execute(migration.create_trigger)
  end

  def down
    migration = AuditMigration.new('registrar')
    execute(migration.drop)
  end
end
