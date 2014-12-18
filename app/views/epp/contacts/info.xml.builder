xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.resData do
      xml.tag!('contact:chkData', 'xmlns:contact' => 'urn:ietf:params:xml:ns:contact-1.0') do
        xml.tag!('contact:id', @contact.code)
        xml << render('/epp/contacts/postal_info')
        xml.tag!('contact:voice', @contact.phone) if @disclosure.try(:phone) || @owner
        xml.tag!('contact:fax', @contact.fax) if @disclosure.try(:fax) || @owner
        xml.tag!('contact:email', @contact.email) if @disclosure.try(:email) || @owner
        #xml.tag!('contact:clID', @current_epp_user.username) if @current_epp_user
        #xml.tag!('contact:crID', @contact.cr_id ) if @contact.cr_id
        xml.tag!('contact:crDate', @contact.created_at)
        xml.tag!('contact:upID', @contact.up_id) if @contact.up_id
        xml.tag!('contact:upDate', @contact.updated_at) unless @contact.updated_at == @contact.created_at
        xml.tag!('contact:ident', @contact.ident, type: @contact.ident_type)
        xml.tag!('contact:trDate', '123') if false
        if @owner
          xml.tag!('contact:authInfo') do
           xml.tag!('contact:pw', @contact.auth_info) # Doc says we have to return this but is it necessary?
          end
        end
        # statuses
        @contact.statuses.each do |cs|
          xml.tag!('contact:status', s: cs.value)
        end
        xml << render('/epp/contacts/disclosure_policy')
      end
    end

    xml << render('/epp/shared/trID')
  end
end
