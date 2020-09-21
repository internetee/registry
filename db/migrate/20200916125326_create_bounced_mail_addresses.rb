class CreateBouncedMailAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :bounced_mail_addresses do |t|
      t.string :email, null: false
      t.string :message_id, null: false
      t.string :bounce_type, null: false
      t.string :bounce_subtype, null: false
      t.string :action, null: false
      t.string :status, null: false
      t.string :diagnostic, null: true

      t.timestamps
    end
  end
end
