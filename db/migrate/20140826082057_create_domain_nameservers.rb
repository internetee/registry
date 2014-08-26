class CreateDomainNameservers < ActiveRecord::Migration
  def change
    create_table :domain_nameservers, id: false do |t|
      t.integer :domain_id
      t.integer :nameserver_id
    end
  end
end
