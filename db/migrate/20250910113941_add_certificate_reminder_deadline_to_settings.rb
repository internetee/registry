class AddCertificateReminderDeadlineToSettings < ActiveRecord::Migration[6.1]
  def up
    unless SettingEntry.exists?(code: 'certificate_reminder_deadline')
      SettingEntry.create!(
        code: 'certificate_reminder_deadline',
        value: '30',
        format: 'integer',
        group: 'certificate'
      )
    else
      puts "SettingEntry certificate_reminder_deadline already exists"
    end
  end

  def down
    SettingEntry.where(code: 'certificate_reminder_deadline').destroy_all
  end
end
