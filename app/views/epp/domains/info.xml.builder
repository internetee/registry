xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.resData do
      xml.tag!('domain:infData', 'xmlns:domain' => 'urn:ietf:params:xml:ns:domain-1.0') do
        xml.tag!('domain:name', @domain.name)
        xml.tag!('domain:status', 's' => @domain.status) if @domain.status
        xml.tag!('domain:registrant', @domain.owner_contact_code)

        @domain.tech_contacts.each do |x|
          xml.tag!('domain:contact', x.code, 'type' => 'tech')
        end

        @domain.admin_contacts.each do |x|
          xml.tag!('domain:contact', x.code, 'type' => 'admin')
        end

        xml.tag!('domain:ns') do
          @domain.nameservers.each do |x|
            xml.tag!('domain:hostObj', x.hostname)
          end
        end

        ## TODO Find out what this domain:host is all about

        xml.tag!('domain:clID', @domain.owner_contact_code)

        xml.tag!('domain:crID', @domain.registrar_name)

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

  xml << render('/epp/shared/trID')
end
