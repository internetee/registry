@disclosure_policy&.each do |k, v|
  xml.tag!('contact:disclose', 'flag' => k) do
    v.each do |attr|
      xml.tag!("contact:#{attr}")
    end
  end
end
