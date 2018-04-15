class RenameInvoicesVatPrcToVatRate < ActiveRecord::Migration
  def change
    rename_column :invoices, :vat_prc, :vat_rate
  end
end
