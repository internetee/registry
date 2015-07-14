# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password]

Rails.application.config.filter_parameters << lambda do |key, value|
  value.to_s.gsub!(/pw>.+<\//, 'pw>[FILTERED]</') if key =~ /frame|raw_frame/i
end
