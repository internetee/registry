class RenameInvoicesVatPrcToVatRate < ActiveRecord::Migration[6.0]
  def change
    rename_column :invoices, :vat_prc, :vat_rate
  end
end
