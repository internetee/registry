class AddInDirectoToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :in_directo, :boolean, default: false
  end
end
