xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.resData do
      xml.tag! 'domain:infData', 'xmlns:domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd' do
        xml.tag!('domain:name', @domain.name)
        xml.tag!('domain:roid', @domain.roid)
        @domain.statuses.each do |s|
          xml.tag!('domain:status', 's' => s)
        end

        xml.tag!('domain:registrant', @domain.registrant.code)

        @domain.tech_contacts.each do |tc|
          xml.tag!('domain:contact', tc.code, 'type' => 'tech')
        end

        @domain.admin_contacts.each do |ac|
          xml.tag!('domain:contact', ac.code, 'type' => 'admin')
        end

        if @nameservers&.any?
          xml.tag!('domain:ns') do
            @nameservers.each do |x|
              xml.tag!('domain:hostAttr') do
                xml.tag!('domain:hostName', x.hostname)
                if x.ipv4.present?
                  x.ipv4.each { |ip| xml.tag!('domain:hostAddr', ip, 'ip' => 'v4') }
                end

                if x.ipv6.present?
                  x.ipv6.each { |ip| xml.tag!('domain:hostAddr', ip, 'ip' => 'v6') }
                end
              end
            end
          end
        end

        xml.tag!('domain:clID', @domain.registrar.code)

        xml.tag!('domain:crID', @domain.cr_id)
        xml.tag!('domain:crDate', @domain.created_at.try(:iso8601))

        if @domain.updated_at > @domain.created_at
          updator = @domain.updator.try(:registrar)
          updator = updator.code if updator.present?
          xml.tag!('domain:upID', updator) if updator.present?
          xml.tag!('domain:upDate', @domain.updated_at.try(:iso8601))
        end

        xml.tag!('domain:exDate', @domain.valid_to.iso8601)

        if can? :view_password, @domain, @password
          xml.tag!('domain:authInfo') do
            xml.tag!('domain:pw', @domain.transfer_code)
          end
        end
      end
    end

    if @domain.dnskeys.any?
      ds_data = Setting.ds_data_allowed ?
                    @domain.dnskeys.find_all { |key| key.ds_digest.present? } : []
      key_data = Setting.key_data_allowed ?
                     @domain.dnskeys.find_all { |key| key.public_key.present? } : []

      if key_data.present? || ds_data.present?
        xml.extension do
          def tag_key_data(xml, key)
            xml.tag!('secDNS:keyData') do
              xml.tag!('secDNS:flags', key.flags)
              xml.tag!('secDNS:protocol', key.protocol)
              xml.tag!('secDNS:alg', key.alg)
              xml.tag!('secDNS:pubKey', key.public_key)
            end
          end

          def tag_ds_data(xml, key)
            xml.tag!('secDNS:dsData') do
              xml.tag!('secDNS:keyTag', key.ds_key_tag)
              xml.tag!('secDNS:alg', key.ds_alg)
              xml.tag!('secDNS:digestType', key.ds_digest_type)
              xml.tag!('secDNS:digest', key.ds_digest)
              tag_key_data(xml, key) if key.public_key.present?
            end
          end

          xml.tag!('secDNS:infData', 'xmlns:secDNS' => 'urn:ietf:params:xml:ns:secDNS-1.1') do
            if Setting.ds_data_allowed
              ds_data.sort.each do |key|
                tag_ds_data(xml, key)
              end
            else
              key_data.sort.each do |key|
                tag_key_data(xml, key)
              end
            end
          end
        end
      end
    end
    render('epp/shared/trID', builder: xml)
  end
end
