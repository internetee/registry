class AddInvoiceNumberToDirecto < ActiveRecord::Migration[6.0]
  def change
    add_column :directos, :invoice_number, :string
    execute "UPDATE directos d SET invoice_number=i.number FROM invoices i WHERE d.item_type='Invoice' AND d.item_id=i.id"
  end
end
