xml.epp_head do
  xml.greeting do
    xml.svID 'EPP server (DSDng)'
    xml.svDate '2014-06-18T17:46:59+03:00'
    xml.svcMenu do
      xml.version '1.0'
      xml.lang 'en'
      xml.objURI 'http://www.nic.cz/xml/epp/contact-1.6'
      xml.objURI 'http://www.nic.cz/xml/epp/domain-1.4'
      xml.objURI 'http://www.nic.cz/xml/epp/nsset-1.2'
      xml.objURI 'http://www.nic.cz/xml/epp/keyset-1.3'
      xml.svcExtension do
        xml.extURI 'http://www.nic.cz/xml/epp/enumval-1.2'
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
