class AddAccountActivityInvoiceIdFk < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :account_activities, :invoices
  end
end
