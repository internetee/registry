class ChangeNameserversDomainIdToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :nameservers, :domain_id, false
  end
end
