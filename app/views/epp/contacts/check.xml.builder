xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.resData do
      xml.tag!('contact:chkData', 'xmlns:contact' => 'urn:ietf:params:xml:ns:contact-1.0') do
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
