class AddRegistrantVerificationToken < ActiveRecord::Migration[6.0]
  def change
    add_column :domains, :registrant_verification_token, :string
    add_index :domains, :registrant_verification_token
  end
end
