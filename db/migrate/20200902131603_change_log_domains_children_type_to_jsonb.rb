class ChangeLogDomainsChildrenTypeToJsonb < ActiveRecord::Migration[6.0]
  def change
    change_column :log_domains, :children, 'jsonb USING children::jsonb'
  end
end
