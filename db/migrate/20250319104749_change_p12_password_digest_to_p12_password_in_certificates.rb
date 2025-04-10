class ChangeP12PasswordDigestToP12PasswordInCertificates < ActiveRecord::Migration[6.1]
  def up
    # Only add p12_password if it doesn't exist
    unless column_exists?(:certificates, :p12_password)
      add_column :certificates, :p12_password, :string
    end

    # Only copy data if p12_password_digest exists
    if column_exists?(:certificates, :p12_password_digest)
      # Use direct SQL to copy data
      execute <<-SQL
        UPDATE certificates 
        SET p12_password = p12_password_digest 
        WHERE p12_password_digest IS NOT NULL
      SQL

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
      # Use direct SQL to copy data
      execute <<-SQL
        UPDATE certificates 
        SET p12_password_digest = p12_password 
        WHERE p12_password IS NOT NULL
      SQL

      safety_assured { remove_column :certificates, :p12_password }
    end
  end
end
