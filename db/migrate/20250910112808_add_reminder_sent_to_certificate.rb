class AddReminderSentToCertificate < ActiveRecord::Migration[6.1]
  def change
    add_column :certificates, :reminder_sent, :boolean, default: false
  end
end
