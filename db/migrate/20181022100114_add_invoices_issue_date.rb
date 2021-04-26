class AddInvoicesIssueDate < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :issue_date, :date
  end
end
