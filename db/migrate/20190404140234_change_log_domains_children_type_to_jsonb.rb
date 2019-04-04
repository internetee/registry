class ChangeLogDomainsChildrenTypeToJsonb < ActiveRecord::Migration
  def change
    change_column :log_domains, :children, 'jsonb USING children::jsonb'
  end
end