class AddNameserversToDomain < ActiveRecord::Migration[6.0]
  def change
    create_table :domains_nameservers do |t|
      t.integer :domain_id
      t.integer :nameserver_id
    end
  end
end
