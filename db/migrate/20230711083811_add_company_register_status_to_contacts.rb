class AddCompanyRegisterStatusToContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :company_register_status, :string
  end
end
