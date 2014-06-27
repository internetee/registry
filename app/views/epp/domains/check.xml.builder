xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.resData do
      xml.tag!('domain:chkData', 'xmlns:domain' => 'http://www.nic.cz/xml/epp/domain-1.4', 'xsi:schemaLocation' => 'http://www.nic.cz/xml/epp/domain-1.4 domain-1.4.xsd') do
        xml.tag!('domain:cd') do
          xml.tag!('domain:name', @domain, 'avail' => 1)
        end
      end
    end

    xml << render('/epp/shared/trID')
  end
end
