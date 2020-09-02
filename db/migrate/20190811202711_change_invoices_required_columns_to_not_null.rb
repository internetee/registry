class ChangeInvoicesRequiredColumnsToNotNull < ActiveRecord::Migration
  def change
    change_column_null :invoices, :buyer_id, false
    change_column_null :invoices, :seller_reg_no, false
    change_column_null :invoices, :seller_bank, false
    change_column_null :invoices, :seller_swift, false
    change_column_null :invoices, :seller_country_code, false
    change_column_null :invoices, :seller_street, false
    change_column_null :invoices, :seller_city, false
    change_column_null :invoices, :buyer_reg_no, false
    change_column_null :invoices, :buyer_country_code, false
    change_column_null :invoices, :buyer_street, false
    change_column_null :invoices, :buyer_city, false
  end
end
