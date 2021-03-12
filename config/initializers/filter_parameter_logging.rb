Rails.application.configure do
  config.filter_parameters += [:password, /^frame$/, /^nokogiri_frame$/, /^parsed_frame$/]
  config.filter_parameters << lambda do |key, value|
    if key == 'raw_frame' && value.respond_to?(:gsub!)
      value.gsub!(/pw>.+<\//, 'pw>[FILTERED]</')
      value.gsub!(/<eis:legalDocument([^>]+)>([^<])+<\/eis:legalDocument>/,
                       "<eis:legalDocument>[FILTERED]</eis:legalDocument>")
    end
  end
end
