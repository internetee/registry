class ChangeReservedDomainsNameToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :reserved_domains, :name, false
  end
end
