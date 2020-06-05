class CreateEmailAddressVerifications < ActiveRecord::Migration[6.0]
  def change
    create_table :email_address_verifications do |t|
      t.string :email, null: false
      t.datetime :verified_at
    end

    add_index :email_address_verifications, :email, unique: true
  end
end
