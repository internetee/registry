class CreateEmailAddressVerifications < ActiveRecord::Migration[6.0]
  def change
    create_table :email_address_verifications do |t|
      t.string :email, null: false
      t.datetime :verified_at
      t.boolean :success, null: false, default: false
      t.string :domain, null: false
    end

    add_index :email_address_verifications, :email, unique: true
    add_index :email_address_verifications, :domain
  end
end
