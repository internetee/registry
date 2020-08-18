class ChangeBlockedDomainsNameToNotNull < ActiveRecord::Migration
  def change
    change_column_null :blocked_domains, :name, false
  end
end
