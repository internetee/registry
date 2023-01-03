class ReverseLogDomainsObjectJson < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      remove_column :log_domains, :object_json if column_exists? :log_domains, :object_json
      add_column :log_domains, :object_json, :json
      Version::DomainVersion.update_all('object_json = object::json')
      rename_column :log_domains, :object, :object_jsonb
      rename_column :log_domains, :object_json, :object
    end
  end

  def down
    safety_assured do
      rename_column :log_domains, :object, :object_json
      rename_column :log_domains, :object_jsonb, :object
    end
  end
end
