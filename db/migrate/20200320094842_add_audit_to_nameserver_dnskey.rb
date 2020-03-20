require 'audit_migration'

class AddAuditToNameserverDnskey < ActiveRecord::Migration[5.1]
  def up
    models = %w[nameserver dnskey]
    models.each do |model|
      migration = AuditMigration.new(model)
      execute(migration.create_table)
      execute(migration.create_trigger)
    end
  end

  def down
    models = %w[nameserver dnskey]
    models.each do |model|
      migration = AuditMigration.new(model)
      execute(migration.drop)
    end
  end
end
