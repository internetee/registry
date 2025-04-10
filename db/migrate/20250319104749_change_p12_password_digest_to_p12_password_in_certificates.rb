class ChangeP12PasswordDigestToP12PasswordInCertificates < ActiveRecord::Migration[6.1]
  def up
    # Only add p12_password if it doesn't exist
    unless column_exists?(:certificates, :p12_password)
      add_column :certificates, :p12_password, :string
    end

    # Only copy data if p12_password_digest exists
    if column_exists?(:certificates, :p12_password_digest)
      Certificate.find_each do |cert|
        cert.update_column(:p12_password, cert.p12_password_digest) if cert.p12_password_digest.present?
      end

      safety_assured { remove_column :certificates, :p12_password_digest }
    end
  end

  def down
    # Only add p12_password_digest if it doesn't exist
    unless column_exists?(:certificates, :p12_password_digest)
      add_column :certificates, :p12_password_digest, :string
    end

    # Only copy data if p12_password exists
    if column_exists?(:certificates, :p12_password)
      Certificate.find_each do |cert|
        cert.update_column(:p12_password_digest, cert.p12_password) if cert.p12_password.present?
      end

      safety_assured { remove_column :certificates, :p12_password }
    end
  end
end
