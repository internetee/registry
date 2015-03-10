xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.resData do
      xml.tag!('contact:infData', 'xmlns:contact' => 'urn:ietf:params:xml:ns:contact-1.0') do
        xml.tag!('contact:id', @contact.code)
        if can? :view_full_info, @contact, @password
          xml.tag!('contact:voice', @contact.phone)
          xml.tag!('contact:email', @contact.email)
          xml.tag!('contact:fax', @contact.fax) if @contact.fax.present?
        end

        xml.tag!('contact:postalInfo', type: 'int') do
          xml.tag!('contact:name', @contact.name)
          if can? :view_full_info, @contact, @password
            xml.tag!('contact:org', @contact.org_name) if @contact.org_name.present?
            xml.tag!('contact:addr') do
              xml.tag!('contact:street', @contact.street)
              xml.tag!('contact:city', @contact.city)
              xml.tag!('contact:pc', @contact.zip)
              xml.tag!('contact:sp', @contact.state)
              xml.tag!('contact:cc', @contact.country_code)
            end
          end
        end

        xml.tag!('contact:clID', @contact.registrar.try(:name))
        xml.tag!('contact:crID', @contact.creator.try(:registrar)) 
        xml.tag!('contact:crDate', @contact.created_at)
        if @contact.updated_at != @contact.created_at
          xml.tag!('contact:upID', @contact.updator.try(:registrar))
          xml.tag!('contact:upDate', @contact.updated_at) 
        end
        xml.tag!('contact:ident', @contact.ident, type: @contact.ident_type, cc: @contact.ident_country_code)
        # xml.tag!('contact:trDate', '123') if false
        if can? :view_password, @contact, @password
          xml.tag!('contact:authInfo') do
           xml.tag!('contact:pw', @contact.auth_info)
          end
        end
        @contact.statuses.each do |status|
          xml.tag!('contact:status', s: status.value)
        end
        # xml << render('/epp/contacts/disclosure_policy')
      end
    end

    xml << render('/epp/shared/trID')
  end
end
