class ReverseLogDomainsObjectChangesJson < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      remove_column :log_domains, :object_changes_json if column_exists? :log_domains, :object_changes_json
      add_column :log_domains, :object_changes_json, :json
      Version::DomainVersion.update_all('object_changes_json = object_changes::json')
      rename_column :log_domains, :object_changes, :object_changes_jsonb
      rename_column :log_domains, :object_changes_json, :object_changes
    end
  end

  def down
    safety_assured do
      rename_column :log_domains, :object_changes, :object_changes_json
      rename_column :log_domains, :object_changes_jsonb, :object_changes
    end
  end
end
