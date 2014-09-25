address = @contact.address
xml.tag!('contact:postalInfo', type: 'int') do # TODO instance method of defining type
  xml.tag!('contact:name', @contact.name) if @contact.disclosure.int_name
  xml.tag!('contact:org', @contact.org_name) if @contact.disclosure.int_org_name
  if @contact.disclosure.int_addr
    xml.tag!('contact:addr') do
      xml.tag!('contact:street', address.street) if address.street
      xml.tag!('contact:street', address.street2) if address.street2
      xml.tag!('contact:street', address.street3) if address.street3
      xml.tag!('contact:cc', address.try(:country).try(:iso)) unless address.try(:country).nil?
    end
  end
end

