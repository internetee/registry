class ChangeEmailVerificationFieldsToCitext < ActiveRecord::Migration[6.0]
  def up
    enable_extension 'citext'
    change_column :email_address_verifications, :email, :citext
    change_column :email_address_verifications, :domain, :citext
  end

  def down
    change_column :email_address_verifications, :email, :string
    change_column :email_address_verifications, :domain, :string
    disable_extension 'citext'
  end
end
