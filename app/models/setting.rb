class Setting < RailsSettings::CachedSettings
  include Versions # version/setting_version.rb

  def self.reload_settings!
    Rails.cache.delete_matched('settings:.*')
  end
end
