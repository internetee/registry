class ChangeNameserversDomainIdToNotNull < ActiveRecord::Migration
  def change
    change_column_null :nameservers, :domain_id, false
  end
end
