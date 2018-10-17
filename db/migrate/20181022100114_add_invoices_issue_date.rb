class AddInvoicesIssueDate < ActiveRecord::Migration
  def change
    add_column :invoices, :issue_date, :date
  end
end
