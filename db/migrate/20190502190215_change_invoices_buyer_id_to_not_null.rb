class ChangeInvoicesBuyerIdToNotNull < ActiveRecord::Migration
  def change
    change_column_null :invoices, :buyer_id, false
  end
end
