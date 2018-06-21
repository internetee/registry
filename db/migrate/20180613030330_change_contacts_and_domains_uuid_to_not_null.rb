class ChangeContactsAndDomainsUuidToNotNull < ActiveRecord::Migration
  def change
    change_column_null :contacts, :uuid, false
    change_column_null :domains, :uuid, false
  end
end
