class AddRecipientJsonToBouncedMailAddress < ActiveRecord::Migration[6.0]
  def change
    add_column :bounced_mail_addresses, :recipient_json, :jsonb, null: false
  end
end
