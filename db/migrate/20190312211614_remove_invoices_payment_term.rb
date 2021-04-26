class RemoveInvoicesPaymentTerm < ActiveRecord::Migration[6.0]
  def change
    remove_column :invoices, :payment_term
  end
end
