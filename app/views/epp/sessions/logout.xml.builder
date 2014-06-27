xml.instruct!
xml.epp('xmlns' => 'urn:ietf:params:xml:ns:epp-1.0', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:schemaLocation' => 'urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd') do
  xml.response do
    xml.result('code' => '1500') do
      xml.msg('Command completed successfully; ending session', 'lang' => 'en')
    end
  end

  xml.trID do
    xml.clTRID params[:clTRID]
    xml.svTRID @svTRID
  end
end
