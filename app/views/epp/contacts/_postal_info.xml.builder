if @contact.international_address
  address = @contact.international_address
  xml.tag!('contact:postalInfo', type: 'int') do # TODO instance method of defining type
    xml.tag!('contact:name', address.name) if @contact.disclosure.int_name
    xml.tag!('contact:org', address.org_name) if @contact.disclosure.int_org_name
    if @contact.disclosure.int_addr
      xml.tag!('contact:addr') do
        xml.tag!('contact:street', address.street) if address.street
        xml.tag!('contact:street', address.street2) if address.street2
        xml.tag!('contact:street', address.street3) if address.street3
        xml.tag!('contact:cc', address.try(:country).try(:iso)) unless address.try(:country).nil?
      end
    end
  end
end
if @contact.local_address
  address = @contact.local_address
  xml.tag!('contact:postalInfo', type: 'loc') do
    xml.tag!('contact:name', address.name) if @contact.disclosure.loc_name
    xml.tag!('contact:org', address.org_name) if @contact.disclosure.loc_org_name
    if @contact.disclosure.loc_addr
      xml.tag!('contact:addr') do
        xml.tag!('contact:street', address.street) if address.street
        xml.tag!('contact:street', address.street2) if address.street2
        xml.tag!('contact:street', address.street3) if address.street3
        xml.tag!('contact:cc', address.try(:country).try(:iso)) unless address.try(:country).nil?
      end
    end
  end
end

