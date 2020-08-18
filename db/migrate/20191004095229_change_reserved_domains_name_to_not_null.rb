class ChangeReservedDomainsNameToNotNull < ActiveRecord::Migration
  def change
    change_column_null :reserved_domains, :name, false
  end
end
