class Setting < RailsSettings::CachedSettings
  include Versions # version/setting_version.rb

  def self.reload_settings!
    STDOUT << "#{Time.zone.now.utc} - Clearing settings cache\n"
    Rails.cache.delete_matched('settings:.*')
    STDOUT << "#{Time.zone.now.utc} - Settings cache cleared\n"
  end
end
