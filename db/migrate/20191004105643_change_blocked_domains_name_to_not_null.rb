class ChangeBlockedDomainsNameToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :blocked_domains, :name, false
  end
end
