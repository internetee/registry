xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.resData do
      xml.tag!('contact:infData', 'xmlns:contact' => 'https://epp.tld.ee/schema/contact-eis-1.0.xsd') do
        xml.tag!('contact:id', @contact.code)
        xml.tag!('contact:roid', @contact.roid)

        @contact.statuses.each do |status|
          xml.tag!('contact:status', s: status)
        end

        xml.tag!('contact:postalInfo', type: 'int') do
          xml.tag!('contact:name', @contact.name)
          if can? :view_full_info, @contact, @password
            xml.tag!('contact:org', @contact.org_name) if @contact.org_name.present?
            xml.tag!('contact:addr') do
              xml.tag!('contact:street', @contact.street)
              xml.tag!('contact:city', @contact.city)
              xml.tag!('contact:sp', @contact.state)
              xml.tag!('contact:pc', @contact.zip)
              xml.tag!('contact:cc', @contact.country_code)
            end
          else
            xml.tag!('contact:org', 'No access')
            xml.tag!('contact:addr') do
              xml.tag!('contact:street', 'No access')
              xml.tag!('contact:city', 'No access')
              xml.tag!('contact:sp', 'No access')
              xml.tag!('contact:pc', 'No access')
              xml.tag!('contact:cc', 'No access')
            end
          end
        end

        if can? :view_full_info, @contact, @password
          xml.tag!('contact:voice', @contact.phone)
          xml.tag!('contact:fax', @contact.fax) if @contact.fax.present?
          xml.tag!('contact:email', @contact.email)
        else
          xml.tag!('contact:voice', 'No access')
          xml.tag!('contact:fax', 'No access')
          xml.tag!('contact:email', 'No access')
        end

        xml.tag!('contact:clID', @contact.registrar.try(:name))
        if @contact.creator.try(:registrar).blank? && Rails.env.test?
          xml.tag!('contact:crID', 'TEST-CREATOR')
        else
          xml.tag!('contact:crID', @contact.creator.try(:registrar))
        end
        xml.tag!('contact:crDate', @contact.created_at.try(:iso8601))
        if @contact.updated_at != @contact.created_at
          xml.tag!('contact:upID', @contact.updator.try(:registrar))
          xml.tag!('contact:upDate', @contact.updated_at.try(:iso8601))
        end
        # xml.tag!('contact:trDate', '123') if false
        if can? :view_password, @contact, @password
          xml.tag!('contact:authInfo') do
           xml.tag!('contact:pw', @contact.auth_info)
          end
        else
          xml.tag!('contact:authInfo') do
          xml.tag!('contact:pw', 'No access')
          end
        end
        # xml << render('/epp/contacts/disclosure_policy')
      end
    end
    if can? :view_full_info, @contact, @password
      xml.tag!('extension') do
        xml.tag!('eis:extdata', 'xmlns:eis' => 'https://epp.tld.ee/schema/eis-1.0.xsd') do
          xml.tag!('eis:ident', @contact.ident,
                   type: @contact.ident_type, cc: @contact.ident_country_code)
        end
      end
    else
      xml.tag!('extension') do
        xml.tag!('eis:extdata', 'xmlns:eis' => 'https://epp.tld.ee/schema/eis-1.0.xsd') do
          xml.tag!('eis:ident', 'No access')
        end
      end
    end

    render('epp/shared/trID', builder: xml)
  end
end
