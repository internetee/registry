class ChangeDomainsValidToToNotNull < ActiveRecord::Migration
  def change
    change_column_null :domains, :valid_to, false
  end
end
