class ChangeInvoicesIssueDateToNotNull < ActiveRecord::Migration
  def change
    change_column_null :invoices, :issue_date, false
  end
end
