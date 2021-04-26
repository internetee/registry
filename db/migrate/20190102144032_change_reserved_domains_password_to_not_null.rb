class ChangeReservedDomainsPasswordToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :reserved_domains, :password, false
  end
end
