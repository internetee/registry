class AddInvoicesDueDateConstraint < ActiveRecord::Migration
  def up
    execute <<~SQL
      ALTER TABLE invoices ADD CONSTRAINT invoices_due_date_is_not_before_issue_date
      CHECK (due_date >= issue_date);
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE invoices DROP CONSTRAINT invoices_due_date_is_not_before_issue_date;
    SQL
  end
end
