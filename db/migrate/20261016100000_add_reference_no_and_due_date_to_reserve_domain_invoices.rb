class AddReferenceNoAndDueDateToReserveDomainInvoices < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :reserve_domain_invoices, :reference_no, :string
    add_column :reserve_domain_invoices, :due_date, :date
    add_index :reserve_domain_invoices, :reference_no, unique: true, where: 'reference_no IS NOT NULL',
                                                       algorithm: :concurrently
  end
end
