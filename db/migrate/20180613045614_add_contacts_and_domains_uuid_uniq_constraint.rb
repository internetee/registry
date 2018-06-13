# Unique constraint is needed to prevent accidental duplicate values in fixtures to appear in DB
class AddContactsAndDomainsUuidUniqConstraint < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE contacts ADD CONSTRAINT uniq_contact_uuid UNIQUE (uuid);
      ALTER TABLE domains ADD CONSTRAINT uniq_domain_uuid UNIQUE (uuid);
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE contacts DROP CONSTRAINT uniq_contact_uuid;
      ALTER TABLE domains DROP CONSTRAINT uniq_domain_uuid;
    SQL
  end
end
