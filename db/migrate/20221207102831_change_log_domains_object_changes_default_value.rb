class ChangeLogDomainsObjectChangesDefaultValue < ActiveRecord::Migration[6.1]
  def change
    change_column_default :log_domains, :object_changes, nil
  end
end
