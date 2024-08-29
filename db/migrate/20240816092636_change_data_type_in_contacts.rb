class ChangeDataTypeInContacts < ActiveRecord::Migration[6.1]
  def up
    safety_assured do
      change_column :contacts, :code, :string, limit: 255
      change_column :contacts, :phone, :string, limit: 255
      change_column :contacts, :email, :string, limit: 255
      change_column :contacts, :fax, :string, limit: 255
      change_column :contacts, :ident, :string, limit: 255
      change_column :contacts, :ident_type, :string, limit: 255
      change_column :contacts, :auth_info, :string, limit: 255
      change_column :contacts, :name, :string, limit: 255
      change_column :contacts, :org_name, :string, limit: 255
    end
  end

  def down
    safety_assured do
      change_column :contacts, :code, :string, limit: nil
      change_column :contacts, :phone, :string, limit: nil
      change_column :contacts, :email, :string, limit: nil
      change_column :contacts, :fax, :string, limit: nil
      change_column :contacts, :ident, :string, limit: nil
      change_column :contacts, :ident_type, :string, limit: nil
      change_column :contacts, :auth_info, :string, limit: nil
      change_column :contacts, :name, :string, limit: nil
      change_column :contacts, :org_name, :string, limit: nil
    end
  end
end
