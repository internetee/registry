class VersionObjectIsJsonb < ActiveRecord::Migration
  def up
    change_column :log_contacts, :object, :jsonb, using: "object::jsonb"
    execute %q(CREATE  INDEX  "log_contacts_object_legacy_id" ON "log_contacts"(cast("object"->>'legacy_id' as int)))
    change_column :log_domains, :object, :jsonb, using: "object::jsonb"
    execute %q(CREATE  INDEX  "log_domains_object_legacy_id" ON "log_contacts"(cast("object"->>'legacy_id' as int)))

    change_column :log_dnskeys, :object, :jsonb, using: "object::jsonb"
    execute %q(CREATE  INDEX  "log_dnskeys_object_legacy_id" ON "log_contacts"(cast("object"->>'legacy_domain_id' as int)))
    change_column :log_nameservers, :object, :jsonb, using: "object::jsonb"
    execute %q(CREATE  INDEX  "log_nameservers_object_legacy_id" ON "log_contacts"(cast("object"->>'legacy_domain_id' as int)))

    add_index :registrars, :legacy_id rescue true
  end
  def down
    change_column :log_contacts,    :object, :json, using: "object::json"
    change_column :log_domains,     :object, :json, using: "object::json"
    change_column :log_dnskeys,     :object, :json, using: "object::json"
    change_column :log_nameservers, :object, :json, using: "object::json"

    drop_index :log_contacts_object_legacy_id
    drop_index :log_domains_object_legacy_id
    drop_index :log_dnskeys_object_legacy_id
    drop_index :log_nameservers_object_legacy_id
  end
end
