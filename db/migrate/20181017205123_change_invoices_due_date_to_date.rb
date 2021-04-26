class ChangeInvoicesDueDateToDate < ActiveRecord::Migration[6.0]
  def change
    change_column :invoices, :due_date, :date, null: false
  end
end
