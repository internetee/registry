class AddNumberToInvoices < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :number, :integer
  end
end
