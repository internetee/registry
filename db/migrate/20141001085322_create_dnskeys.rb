class CreateDnskeys < ActiveRecord::Migration[6.0]
  def change
    create_table :dnskeys do |t|
      t.integer :domain_id
      t.integer :flags
      t.integer :protocol
      t.integer :alg
      t.string :public_key
    end
  end
end
