class ChangeRegistrarAccountingCustomerCodeToNotNull < ActiveRecord::Migration
  def change
    change_column_null :registrars, :accounting_customer_code, false
  end
end
