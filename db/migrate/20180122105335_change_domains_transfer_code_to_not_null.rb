class ChangeDomainsTransferCodeToNotNull < ActiveRecord::Migration
  def change
    change_column_null :domains, :transfer_code, false
  end
end
