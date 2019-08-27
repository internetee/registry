class AddInvoicesNumberUniqConstraint < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE invoices ADD CONSTRAINT unique_number UNIQUE (number)
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE invoices DROP CONSTRAINT unique_number
    SQL
  end
end
