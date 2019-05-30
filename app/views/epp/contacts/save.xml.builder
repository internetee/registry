xml.epp_head do
  xml.response do
    xml.result('code' => @response_code) do
      xml.msg @response_description
    end

    xml.resData do
      xml.tag!('contact:creData', 'xmlns:contact' => 'https://epp.tld.ee/schema/contact-ee-1.1.xsd') do
        xml.tag!('contact:id', @contact.code)
        xml.tag!('contact:crDate', @contact.created_at.try(:iso8601))
      end
    end

    render('epp/shared/trID', builder: xml)
  end
end
