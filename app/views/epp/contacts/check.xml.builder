xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.resData do
      xml.tag!('contact:chkData', 'xmlns:contact' => 'http://www.nic.cz/xml/epp/contact-1.6', 
               'xsi:schemaLocation' => 'http://www.nic.cz/xml/epp/contact-1.6 contact-1.6.xsd') do
         #xml.tag!('contact:id', @contact.code)
        @contacts.each do |contact|
          xml.tag!('contact:cd') do
            xml.tag! "contact:id", contact[:code], avail: contact[:avail]
            xml.tag!('contact:reason', contact[:reason]) unless contact[:avail] == 1
          end
        end
      end
    end

    xml << render('/epp/shared/trID')
  end
end
