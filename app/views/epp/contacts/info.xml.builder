xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.resData do
      xml.tag!('contact:chkData', 'xmlns:contact' => 'urn:ietf:params:xml:ns:contact-1.0') do
        xml << render('/epp/contacts/postal_info')
        xml.tag!('contact:voice', @contact.phone) if @contact.disclosure.phone
        xml.tag!('contact:fax', @contact.fax) if @contact.disclosure.fax
        xml.tag!('contact:email', @contact.email) if @contact.disclosure.email
        xml.tag!('contact:clID', @current_epp_user.username) if @current_epp_user
        xml.tag!('contact:crID', @contact.cr_id ) if @contact.cr_id
        xml.tag!('contact:crDate', @contact.created_at)
        xml.tag!('contact:upID', @contact.up_id) if @contact.up_id
        xml.tag!('contact:upDate', @contact.updated_at) unless @contact.updated_at == @contact.created_at
        xml.tag!('contact:trDate', '123') if false
        xml.tag!('contact:authInfo') do
          xml.tag!('contact:pw', @contact.auth_info) # Doc says we have to return this but is it necessary?
        end
        xml.tag!('contact:disclose', '123') if false

      end
    end

    xml << render('/epp/shared/trID')
  end
end
