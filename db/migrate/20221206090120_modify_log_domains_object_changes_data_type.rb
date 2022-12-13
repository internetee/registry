class ModifyLogDomainsObjectChangesDataType < ActiveRecord::Migration[6.1]
  def up
    add_column :log_domains, :object_changes_jsonb, :jsonb, default: '{}'

    # Copy data from old column to the new one
    Version::DomainVersion.update_all('object_changes_jsonb = object_changes::jsonb')

    # Rename columns instead of modify their type, it's way faster
    safety_assured do
      rename_column :log_domains, :object_changes, :object_changes_json
      rename_column :log_domains, :object_changes_jsonb, :object_changes
    end
  end

  def down
    safety_assured do
      rename_column :log_domains, :object_changes, :object_changes_jsonb
      rename_column :log_domains, :object_changes_json, :object_changes
    end
  end
end