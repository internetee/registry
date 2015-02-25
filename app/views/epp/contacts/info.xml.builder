xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.resData do
      xml.tag!('contact:chkData', 'xmlns:contact' => 'urn:ietf:params:xml:ns:contact-1.0') do
        xml.tag!('contact:id', @contact.code)
        xml << render('/epp/contacts/postal_info')
        xml.tag!('contact:voice', @contact.phone) #if @disclosure.try(:phone) || @owner
        xml.tag!('contact:fax', @contact.fax) #if @disclosure.try(:fax) || @owner
        xml.tag!('contact:email', @contact.email) #if @disclosure.try(:email) || @owner
        xml.tag!('contact:clID', @contact.registrar.try(:name))
        xml.tag!('contact:crID', @contact.creator.try(:registrar)) 
        xml.tag!('contact:crDate', @contact.created_at)
        if @contact.updated_at != @contact.created_at
          xml.tag!('contact:upID', @contact.updator.try(:registrar))
          xml.tag!('contact:upDate', @contact.updated_at) 
        end
        xml.tag!('contact:ident', @contact.ident, type: @contact.ident_type, cc: @contact.ident_country_code)
        # xml.tag!('contact:trDate', '123') if false
        if can? :view_password, @contact
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
