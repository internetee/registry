class AddCheckedCompanyAtToContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :checked_company_at, :datetime
  end
end
