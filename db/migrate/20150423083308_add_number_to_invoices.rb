class AddNumberToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :number, :integer
    Invoice.all.each(&:save)
  end
end
