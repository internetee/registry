xml.epp_head do
  xml.greeting do
    xml.svID 'EPP server (EIS)'
    xml.svDate Time.now.utc.iso8601
    xml.svcMenu do
      xml.version '1.0'
      xml.lang 'en'
      xml.objURI 'urn:ietf:params:xml:ns:domain-1.0'
      xml.objURI 'urn:ietf:params:xml:ns:contact-1.0'
      xml.objURI 'urn:ietf:params:xml:ns:host-1.0'
      xml.objURI 'urn:ietf:params:xml:ns:keyrelay-1.0'
      xml.svcExtension do
        xml.extURI 'urn:ietf:params:xml:ns:secDNS-1.1'
        xml.extURI 'urn:ee:eis:xml:epp:eis-1.0'
      end
    end

    xml.dcp do
      xml.access do
        xml.all
      end
      xml.statement do
        xml.purpose do
          xml.admin
          xml.prov
        end
        xml.recipient do
          xml.public
        end
        xml.retention do
          xml.stated
        end
      end
    end
  end #greeting
end
