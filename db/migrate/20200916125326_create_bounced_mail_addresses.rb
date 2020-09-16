class CreateBouncedMailAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :bounced_mail_addresses do |t|
      t.string :email, null: false
      t.string :bounce_reason, null: false
      t.integer :incidents, null: false, default: 1
      t.jsonb :response_json

      t.timestamps
    end
  end
end
