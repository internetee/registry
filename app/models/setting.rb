class Setting < RailsSettings::CachedSettings
  include Versions # version/setting_version.rb

  def self.reload_settings!
    STDOUT << "#{Time.zone.now.utc} - Clearing settings cache\n"
    Rails.cache.delete_matched('settings:.*')
    STDOUT << "#{Time.zone.now.utc} - Settings cache cleared\n"
  end


  # cannot do instance validation because CachedSetting use save!
  def self.params_errors(params)
    errors = {}
    # DS data allowed and Allow key data cannot be both true
    if !!params["key_data_allowed"] && params["key_data_allowed"] == params["ds_data_allowed"]
      msg = "#{I18n.t(:key_data_allowed)} and #{I18n.t(:ds_data_with_key_allowed)} cannot be both true"
      errors["key_data_allowed"] = msg
      errors["ds_data_allowed"]  = msg
    end

    return errors
  end
end
