class AcceptPdfInvoices < ActiveRecord::Migration[6.1]
  def change
    add_column :registrars, :accept_pdf_invoices, :boolean, default: true
  end
end
