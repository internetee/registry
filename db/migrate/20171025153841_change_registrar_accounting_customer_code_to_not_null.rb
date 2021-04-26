class ChangeRegistrarAccountingCustomerCodeToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :registrars, :accounting_customer_code, false
  end
end
