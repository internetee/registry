xml.tag!('contact:postalInfo', type: 'int') do
  xml.tag!('contact:name', @contact.name) #if @disclosure.try(:[], :name) || @owner
  xml.tag!('contact:org', @contact.org_name) #if @disclosure.try(:[], :org_name) || @owner
  # if @disclosure.try(:addr) || @owner
    xml.tag!('contact:addr') do
      xml.tag!('contact:street', @contact.street)
      xml.tag!('contact:city', @contact.city)
      xml.tag!('contact:pc', @contact.zip)
      xml.tag!('contact:sp', @contact.state)
      xml.tag!('contact:cc', @contact.country_code)
    end
  # end
end
