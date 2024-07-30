class CreateReservedDomainStatuses < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    create_table :reserved_domain_statuses do |t|
      t.string :name, null: false
      t.string :access_token, null: false
      t.datetime :token_created_at, null: false
      t.index :access_token, unique: true, algorithm: :concurrently
      t.references :reserved_domain, null: true, foreign_key: true
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
