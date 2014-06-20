xml.instruct!
xml.epp('xmlns' => 'urn:ietf:params:xml:ns:epp-1.0', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:schemaLocation' => 'urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd') do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg('Command completed successfully', 'lang' => 'en')
    end
  end

  xml.trID do
    xml.clTRID 'sample1trid'
  end
end
