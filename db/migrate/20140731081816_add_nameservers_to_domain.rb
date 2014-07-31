class AddNameserversToDomain < ActiveRecord::Migration
  def change
    create_table :domains_nameservers do |t|
      t.integer :domain_id
      t.integer :nameserver_id
    end
  end
end
