class AddFieldsToBouncedMailAddresses < ActiveRecord::Migration[6.0]
  def change
    add_column :bounced_mail_addresses, :additional_error_description, :json
  end
end
