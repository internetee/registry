class AddP12FieldsToCertificates < ActiveRecord::Migration[6.1]
  def change
    add_column :certificates, :private_key, :binary
    add_column :certificates, :p12, :binary
    add_column :certificates, :p12_password_digest, :string
    add_column :certificates, :expires_at, :timestamp
  end
end
