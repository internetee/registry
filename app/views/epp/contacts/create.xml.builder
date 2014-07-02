xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.resData do
      xml.tag!('contact:creData', 'xmlns:contact' => 'http://www.nic.cz/xml/epp/contact-1.6', 'xsi:schemaLocation' => 'http://www.nic.cz/xml/epp/contact-1.6 contact-1.6.xsd') do
         xml.tag!('contact:id', @id)
         xml.tag!('contact:crDate', @crDate)
      end
    end

    xml << render('/epp/shared/trID')
  end
end
