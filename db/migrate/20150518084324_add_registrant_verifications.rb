class AddRegistrantVerifications < ActiveRecord::Migration[6.0]
  def change
    create_table :registrant_verifications do |t|
      t.string :domain_name
      t.string :verification_token
      t.timestamps
    end
    add_index :registrant_verifications, :created_at
  end
end
