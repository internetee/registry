class ChangeInvoicesIssueDateToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :invoices, :issue_date, false
  end
end
