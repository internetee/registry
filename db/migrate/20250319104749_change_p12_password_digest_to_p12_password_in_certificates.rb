class ChangeP12PasswordDigestToP12PasswordInCertificates < ActiveRecord::Migration[6.1]
  def up
    add_column :certificates, :p12_password, :string

    Certificate.find_each do |cert|
      cert.update_column(:p12_password, cert.p12_password_digest)
    end

    safety_assured { remove_column :certificates, :p12_password_digest }
  end

  def down
    add_column :certificates, :p12_password_digest, :string

    Certificate.find_each do |cert|
      cert.update_column(:p12_password_digest, cert.p12_password)
    end

    safety_assured { remove_column :certificates, :p12_password }
  end
end
