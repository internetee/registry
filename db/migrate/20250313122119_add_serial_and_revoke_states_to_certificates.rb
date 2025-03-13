class AddSerialAndRevokeStatesToCertificates < ActiveRecord::Migration[6.1]
  def change
    add_column :certificates, :serial, :string, null: true
    add_column :certificates, :revoked_at, :datetime, null: true
    add_column :certificates, :revoked_reason, :integer, null: true
  end
end
