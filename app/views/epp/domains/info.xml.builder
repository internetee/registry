xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.resData do
      xml.tag!('domain:infData', 'xmlns:domain' => 'urn:ietf:params:xml:ns:domain-1.0') do
        xml.tag!('domain:name', @domain.name)
        @domain.domain_statuses.each do |x|
          xml.tag!('domain:status', x.description, 's' => x.value) unless x.description.blank?
          xml.tag!('domain:status', 's' => x.value) if x.description.blank?
        end

        xml.tag!('domain:registrant', @domain.owner_contact_code)

        @domain.tech_contacts.each do |x|
          xml.tag!('domain:contact', x.code, 'type' => 'tech')
        end

        @domain.admin_contacts.each do |x|
          xml.tag!('domain:contact', x.code, 'type' => 'admin')
        end

        xml.tag!('domain:ns') do
          @domain.nameservers.each do |x|
            xml.tag!('domain:hostAttr') do
              xml.tag!('domain:hostName', x.hostname)
              xml.tag!('domain:hostAddr', x.ipv4, 'ip' => 'v4') if x.ipv4.present?
              xml.tag!('domain:hostAddr', x.ipv6, 'ip' => 'v6') if x.ipv6.present?
            end
          end
        end

        ## TODO Find out what this domain:host is all about

        xml.tag!('domain:clID', @domain.registrar_name)

        xml.tag!('domain:crID', @domain.creator.try(:registrar))

        xml.tag!('domain:crDate', @domain.created_at)

        xml.tag!('domain:exDate', @domain.valid_to)

        # TODO Make domain stampable
        #xml.tag!('domain:upID', @domain.updated_by)

        xml.tag!('domain:upDate', @domain.updated_at) if @domain.updated_at != @domain.created_at

        # TODO Make domain transferrable
        #xml.tag!('domain:trDate', @domain.transferred_at) if @domain.transferred_at

        xml.tag!('domain:authInfo') do
          xml.tag!('domain:pw', @domain.auth_info)
        end
      end
    end
  end

  xml.extension do
    xml.tag!('secDNS:infData', 'xmlns:secDNS' => 'urn:ietf:params:xml:ns:secDNS-1.1') do
      @domain.dnskeys.each do |x|
        xml.tag!('secDNS:dsData') do
          xml.tag!('secDNS:keyTag', x.ds_key_tag)
          xml.tag!('secDNS:alg', x.ds_alg)
          xml.tag!('secDNS:digestType', x.ds_digest_type)
          xml.tag!('secDNS:digest', x.ds_digest)
          xml.tag!('secDNS:keyData') do
            xml.tag!('secDNS:flags', x.flags)
            xml.tag!('secDNS:protocol', x.protocol)
            xml.tag!('secDNS:alg', x.alg)
            xml.tag!('secDNS:pubKey', x.public_key)
          end
        end
      end
    end
  end if @domain.dnskeys.any?

  xml << render('/epp/shared/trID')
end
