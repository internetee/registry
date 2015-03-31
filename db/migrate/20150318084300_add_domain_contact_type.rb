class AddDomainContactType < ActiveRecord::Migration
  def change
    add_column :domain_contacts, :type, :string
  end
end
