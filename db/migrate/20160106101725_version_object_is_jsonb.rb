class VersionObjectIsJsonb < ActiveRecord::Migration
  def up
    change_column :log_contacts, :object, :jsonb, using: "object::jsonb"
    execute %q(CREATE  INDEX  "log_contacts_object_legacy_id" ON "log_contacts"(cast("object"->>'legacy_id' as int)))
    add_index :registrars, :legacy_id
  end
  def down
    change_column :log_contacts, :object, :json, using: "object::json"
  end
end
