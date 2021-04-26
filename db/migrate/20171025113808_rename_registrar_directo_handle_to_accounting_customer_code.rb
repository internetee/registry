class RenameRegistrarDirectoHandleToAccountingCustomerCode < ActiveRecord::Migration[6.0]
  def change
    rename_column :registrars, :directo_handle, :accounting_customer_code
  end
end
