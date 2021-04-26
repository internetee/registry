class AddDomainContactType < ActiveRecord::Migration[6.0]
  def change
    add_column :domain_contacts, :type, :string
  end
end
