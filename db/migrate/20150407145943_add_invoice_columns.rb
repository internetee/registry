class AddInvoiceColumns < ActiveRecord::Migration
  def change
    # invoice info
    # invoice number comes from id
    add_column :invoices, :invoice_type, :string, null: false # CRE / DEB
    add_column :invoices, :document_name, :string, null: false # Arve
    add_column :invoices, :due_date, :datetime, null: false
    add_column :invoices, :payment_term, :string # maksetingimus (free text)

    add_column :invoices, :currency, :string, null: false
    add_column :invoices, :description, :string, null: false # Selgitus
    add_column :invoices, :reference_no, :string # Viitenumber
    add_column :invoices, :total_sum, :decimal

    # seller info
    add_column :invoices, :seller_name, :string, null: false
    add_column :invoices, :seller_reg_no, :string
    add_column :invoices, :seller_iban, :string, null: false
    add_column :invoices, :seller_bank, :string, null: false
    add_column :invoices, :seller_swift, :string, null: false
    add_column :invoices, :seller_vat_no, :string

    add_column :invoices, :seller_street, :string
    add_column :invoices, :seller_city, :string
    add_column :invoices, :seller_zip, :string
    add_column :invoices, :seller_phone, :string
    add_column :invoices, :seller_url, :string
    add_column :invoices, :seller_email, :string

    add_column :invoices, :seller_contact_name, :string

    # payer info
    add_column :invoices, :payer_name, :string, null: false
    add_column :invoices, :payer_reg_no, :string, null: false

    add_column :invoices, :payer_street, :string
    add_column :invoices, :payer_city, :string
    add_column :invoices, :payer_zip, :string
    add_column :invoices, :payer_phone, :string
    add_column :invoices, :payer_url, :string
    add_column :invoices, :payer_email, :string

    # MIGRATION TO invoice_rows / invoice_items
    # add_column :invoices, :serial_number, :string # kauba seeria kood
    add_column :invoices, :product_code, :string # teenuse kood müüja süsteemis (sellerProductId)
    add_column :invoices, :description, :string, null: false
    add_column :invoices, :item_unit, :string
    add_column :invoices, :item_amount, :integer
    add_column :invoices, :item_price, :decimal # without taxes and discounts
    add_column :invoices, :item_sum, :decimal # could calculate on the fly (amount * price) (without taxes and discounts)
    add_column :invoices, :vat_sum, :decimal # could calculate on the fly
    add_column :invoices, :item_total_sum, :decimal # could calculate on the fly (row's total sum with taxes)



    ###
    add_column :invoices, :seller_address, :string
    add_column :invoices, :seller_name, :string

    add_column :invoices, :buyer_name, :string
    add_column :invoices, :buyer_reg_no, :string
  end
end
