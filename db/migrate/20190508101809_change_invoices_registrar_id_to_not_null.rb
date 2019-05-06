class ChangeInvoicesRegistrarIdToNotNull < ActiveRecord::Migration
  def change
    change_column_null :invoices, :registrar_id, false
  end
end