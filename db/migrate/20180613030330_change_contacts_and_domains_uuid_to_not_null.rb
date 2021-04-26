class ChangeContactsAndDomainsUuidToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :contacts, :uuid, false
    change_column_null :domains, :uuid, false
  end
end
