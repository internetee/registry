xml.instruct!
xml.epp('xmlns' => 'urn:ietf:params:xml:ns:epp-1.0', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:schemaLocation' => 'urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd') do
  xml.response do
    xml.result('code' => '2501') do
      xml.msg('Authentication error; server closing connection')
    end
  end

  xml.trID do
    xml.clTRID params[:clTRID]
    xml.svTRID @svTRID
  end
end
