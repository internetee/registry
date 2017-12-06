class RenameRegistrarDirectoHandleToAccountingCustomerCode < ActiveRecord::Migration
  def change
    rename_column :registrars, :directo_handle, :accounting_customer_code
  end
end
