require 'audit_migration'

class AddNewVersioningToModels < ActiveRecord::Migration[5.1]

  MODELS = %w[account_activity
              account
              action
              bank_statement
              bank_transaction
              blocked_domain
              certificate
              domain_contact
              invoice_item
              invoice
              notification
              payment_order
              registrant_verification
              reserved_domain
              setting
              user
              white_ip].freeze

  def up
    MODELS.each do |model|
      migration = AuditMigration.new(model)
      execute(migration.create_table)
      execute(migration.create_trigger)
    end
  end

  def down
    MODELS.each do |model|
      migration = AuditMigration.new(model)
      execute(migration.drop)
    end
  end
end
