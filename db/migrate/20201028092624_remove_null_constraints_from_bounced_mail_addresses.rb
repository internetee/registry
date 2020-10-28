class RemoveNullConstraintsFromBouncedMailAddresses < ActiveRecord::Migration[6.0]
  def up
    change_column_null :bounced_mail_addresses, :message_id, true
    change_column_null :bounced_mail_addresses, :bounce_type, true
    change_column_null :bounced_mail_addresses, :bounce_subtype, true
    change_column_null :bounced_mail_addresses, :action, true
    change_column_null :bounced_mail_addresses, :status, true
  end

  def down
    change_column_null :bounced_mail_addresses, :message_id, false
    change_column_null :bounced_mail_addresses, :bounce_type, false
    change_column_null :bounced_mail_addresses, :bounce_subtype, false
    change_column_null :bounced_mail_addresses, :action, false
    change_column_null :bounced_mail_addresses, :status, false
  end
end
