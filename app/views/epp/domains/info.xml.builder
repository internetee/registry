xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.resData do
      xml.tag!('domain:infData', 'xmlns:domain' => 'urn:ietf:params:xml:ns:domain-1.0') do
        xml.tag!('domain:name', @domain.name)
        @domain.domain_statuses.each do |ds|
          xml.tag!('domain:status', ds.description, 's' => ds.value) unless ds.description.blank?
          xml.tag!('domain:status', 's' => ds.value) if ds.description.blank?
        end

        xml.tag!('domain:registrant', @domain.registrant_code)

        @domain.tech_contacts.each do |tc|
          xml.tag!('domain:contact', tc.code, 'type' => 'tech')
        end

        @domain.admin_contacts.each do |ac|
          xml.tag!('domain:contact', ac.code, 'type' => 'admin')
        end

        if @nameservers && @nameservers.any?
          xml.tag!('domain:ns') do
            @nameservers.each do |x|
              xml.tag!('domain:hostAttr') do
                xml.tag!('domain:hostName', x.hostname)
                xml.tag!('domain:hostAddr', x.ipv4, 'ip' => 'v4') if x.ipv4.present?
                xml.tag!('domain:hostAddr', x.ipv6, 'ip' => 'v6') if x.ipv6.present?
              end
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

        if can? :view_password, @domain, @password
          xml.tag!('domain:authInfo') do
            xml.tag!('domain:pw', @domain.auth_info)
          end
        end
      end
    end
  end

  xml.extension do
    xml.tag!('secDNS:infData', 'xmlns:secDNS' => 'urn:ietf:params:xml:ns:secDNS-1.1') do
      @domain.dnskeys.each do |key|
        xml.tag!('secDNS:dsData') do
          xml.tag!('secDNS:keyTag', key.ds_key_tag)
          xml.tag!('secDNS:alg', key.ds_alg)
          xml.tag!('secDNS:digestType', key.ds_digest_type)
          xml.tag!('secDNS:digest', key.ds_digest)
          xml.tag!('secDNS:keyData') do
            xml.tag!('secDNS:flags', key.flags)
            xml.tag!('secDNS:protocol', key.protocol)
            xml.tag!('secDNS:alg', key.alg)
            xml.tag!('secDNS:pubKey', key.public_key)
          end
        end
      end
    end
  end if @domain.dnskeys.any?

  xml << render('/epp/shared/trID')
end
