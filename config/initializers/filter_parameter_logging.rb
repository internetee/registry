Rails.application.configure do
  config.filter_parameters += [:password, :nokogiri_frame, :parsed_frame]
  config.filter_parameters << lambda do |key, value|
    value.to_s.gsub!(/pw>.+<\//, 'pw>[FILTERED]</') if key =~ /^(frame|raw_frame)$/i
  end
end
