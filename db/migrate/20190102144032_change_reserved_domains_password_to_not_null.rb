class ChangeReservedDomainsPasswordToNotNull < ActiveRecord::Migration
  def change
    change_column_null :reserved_domains, :password, false
  end
end
