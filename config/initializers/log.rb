Rails.application.configure do
  config.filter_parameters += [:password, :nokogiri_frame, :parsed_frame]
end
