class ChangeNameserversHostnameToNotNull < ActiveRecord::Migration
  def change
    change_column_null :nameservers, :hostname, false
  end
end
