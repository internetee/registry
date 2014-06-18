xml.instruct!
xml.epp('xmlns' => 'urn:ietf:params:xml:ns:epp-1.0', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:schemaLocation' => 'urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd') do
  xml.svID 'EPP server (DSDng)'
  xml.svDate '2014-06-18T17:46:59+03:00'
  xml.version '1.0'
  xml.lang 'en'
  xml.lang 'cs'
  xml.objURI 'http://www.nic.cz/xml/epp/contact-1.6'
  xml.objURI 'http://www.nic.cz/xml/epp/domain-1.4'
  xml.objURI 'http://www.nic.cz/xml/epp/nsset-1.2'
  xml.objURI 'http://www.nic.cz/xml/epp/keyset-1.3'
  xml.svcExtension do
    xml.extURI 'http://www.nic.cz/xml/epp/enumval-1.2'
  end
end
