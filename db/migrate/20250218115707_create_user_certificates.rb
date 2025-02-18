class CreateUserCertificates < ActiveRecord::Migration[6.1]
  def change
    create_table :user_certificates do |t|
      t.references :user, null: false, foreign_key: true
      t.binary :private_key, null: false
      t.text :csr
      t.text :certificate
      t.binary :p12
      t.string :status
      t.datetime :expires_at
      t.datetime :revoked_at
      t.string :p12_password_digest
      
      t.timestamps
    end

    add_index :user_certificates, [:user_id, :status]
  end
end
