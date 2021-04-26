class ChangeDomainsValidToToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :domains, :valid_to, false
  end
end
