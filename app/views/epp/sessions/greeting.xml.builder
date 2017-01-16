xml.epp_head do
  xml.greeting do
    xml.svID 'EPP server (EIS)'
    xml.svDate Time.zone.now.utc.iso8601
    xml.svcMenu do
      xml.version '1.0'
      xml.lang 'en'
      xml.objURI 'https://epp.tld.ee/schema/domain-eis-1.0.xsd'
      xml.objURI 'https://epp.tld.ee/schema/contact-ee-1.1.xsd'
      xml.objURI 'urn:ietf:params:xml:ns:host-1.0'
      xml.objURI 'urn:ietf:params:xml:ns:keyrelay-1.0'
      xml.svcExtension do
        xml.extURI 'urn:ietf:params:xml:ns:secDNS-1.1'
        xml.extURI 'https://epp.tld.ee/schema/ee-1.1.xsd'
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
