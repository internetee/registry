class ModifyLogDomainsObjectDataType < ActiveRecord::Migration[6.1]
  def up
    add_column :log_domains, :object_jsonb, :jsonb

    # Copy data from old column to the new one
    Version::DomainVersion.update_all('object_jsonb = object::jsonb')

    # Rename columns instead of modify their type, it's way faster
    safety_assured do
      rename_column :log_domains, :object, :object_json
      rename_column :log_domains, :object_jsonb, :object
    end
  end

  def down
    safety_assured do
      rename_column :log_domains, :object, :object_jsonb
      rename_column :log_domains, :object_json, :object
    end
  end
end
