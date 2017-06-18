class AddAccountActivityInvoiceIdFk < ActiveRecord::Migration
  def change
    add_foreign_key :account_activities, :invoices
  end
end
