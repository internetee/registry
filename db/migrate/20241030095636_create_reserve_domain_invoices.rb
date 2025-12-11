class CreateReserveDomainInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :reserve_domain_invoices do |t|
      t.string :invoice_number
      t.string :domain_names, array: true, default: []

      t.timestamps
    end

    add_index :reserve_domain_invoices, :invoice_number
  end
end
