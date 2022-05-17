builder.tag!('contact:chkData', 'xmlns:contact' =>
  Xsd::Schema.filename(for_prefix: 'contact-ee', for_version: '1.1')) do
  results.each do |result|
    builder.tag!('contact:cd') do
      builder.tag! 'contact:id', result[:code], avail: result[:avail]
      # builder.tag!('contact:reason', result[:reason]) unless result[:avail] == 1
    end
  end
end
