class CreateDomainTransfer < ActiveRecord::Migration
  def change
    create_table :domain_transfers do |t|
      t.integer :domain_id
      t.string :status
      t.datetime :transfer_requested_at
      t.datetime :transferred_at
      t.integer :transfer_from_id
      t.integer :transfer_to_id

      t.timestamps
    end
  end
end
