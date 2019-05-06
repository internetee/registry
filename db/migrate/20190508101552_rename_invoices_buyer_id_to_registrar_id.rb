class RenameInvoicesBuyerIdToRegistrarId < ActiveRecord::Migration
  def change
    rename_column :invoices, :buyer_id, :registrar_id
  end
end