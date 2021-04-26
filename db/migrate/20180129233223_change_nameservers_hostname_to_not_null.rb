class ChangeNameserversHostnameToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :nameservers, :hostname, false
  end
end
