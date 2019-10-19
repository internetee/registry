namespace :data_migrations do
  task rename_setting: :environment do
    Setting.transaction do
      Setting.destroy(:request_confrimation_on_registrant_change_enabled)
      Setting.verify_registrant_change = true
    end
  end
end
