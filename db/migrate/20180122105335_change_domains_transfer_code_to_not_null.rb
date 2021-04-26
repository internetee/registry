class ChangeDomainsTransferCodeToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :domains, :transfer_code, false
  end
end
