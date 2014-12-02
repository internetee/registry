address = @contact.address
xml.tag!('contact:postalInfo', type: 'int') do
  xml.tag!('contact:name', @contact.name) if @disclosure.try(:[], :name) || @owner
  xml.tag!('contact:org', @contact.org_name) if @disclosure.try(:[], :org_name) || @owner
  if @disclosure.try(:addr) || @owner
    xml.tag!('contact:addr') do
      xml.tag!('contact:street', address.street) if address
      xml.tag!('contact:cc', address.try(:country).try(:iso)) unless address.try(:country).nil?
      xml.tag!('contact:city', address.city) if address
    end
  end
end

