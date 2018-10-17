class RemoveInvoicesPaymentTerm < ActiveRecord::Migration
  def change
    remove_column :invoices, :payment_term
  end
end
