class AddDomainNameToDisputes < ActiveRecord::Migration
  def change
    add_column :disputes, :domain_name, :string
  end
end
