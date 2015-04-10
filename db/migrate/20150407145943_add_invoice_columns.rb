class AddInvoiceColumns < ActiveRecord::Migration
  def change
    # invoice info
    # invoice number comes from id # e-invoice
    add_column :invoices, :invoice_type, :string, null: false # CRE / DEB # e-invoice
    # add_column :invoices, :document_name, :string, null: false # Invoice / credit invoice ... # e-invoice
    add_column :invoices, :due_date, :datetime, null: false # e-invoice
    add_column :invoices, :payment_term, :string # free text

    add_column :invoices, :currency, :string, null: false # e-invoice
    add_column :invoices, :description, :string

    add_column :invoices, :reference_no, :string
    add_column :invoices, :vat_prc, :decimal, null: false
    #add_column :invoices, :total_sum, :decimal # calculate on the fly # e-invoice
    add_column :invoices, :paid_at, :datetime # maybe figure this out from transactions

    # seller info
    # add_column :invoices, :sellable_id, :integer # EIS is actually a registrar itself and invoice can belong to EIS
    # add_column :invoices, :sellable_type, :string

    add_column :invoices, :seller_id, :integer
    add_column :invoices, :seller_name, :string, null: false # e-invoice
    add_column :invoices, :seller_reg_no, :string
    add_column :invoices, :seller_iban, :string, null: false # e-invoice
    add_column :invoices, :seller_bank, :string
    add_column :invoices, :seller_swift, :string
    add_column :invoices, :seller_vat_no, :string

    add_column :invoices, :seller_country_code, :string
    add_column :invoices, :seller_state, :string
    add_column :invoices, :seller_street, :string
    add_column :invoices, :seller_city, :string
    add_column :invoices, :seller_zip, :string
    add_column :invoices, :seller_phone, :string
    add_column :invoices, :seller_url, :string
    add_column :invoices, :seller_email, :string

    add_column :invoices, :seller_contact_name, :string

    # buyer info
    # add_column :invoices, :payable_id, :integer
    # add_column :invoices, :payable_type, :string
    add_column :invoices, :buyer_id, :integer

    add_column :invoices, :buyer_name, :string, null: false # e-invoice
    add_column :invoices, :buyer_reg_no, :string

    add_column :invoices, :buyer_country_code, :string
    add_column :invoices, :buyer_state, :string
    add_column :invoices, :buyer_street, :string
    add_column :invoices, :buyer_city, :string
    add_column :invoices, :buyer_zip, :string
    add_column :invoices, :buyer_phone, :string
    add_column :invoices, :buyer_url, :string
    add_column :invoices, :buyer_email, :string

    # add_column :invoices, :buyer_contact_name, :string
  end
end

