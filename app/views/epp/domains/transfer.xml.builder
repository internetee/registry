xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.resData do
      xml.tag!('domain:trnData', 'xmlns:domain' => 'urn:ietf:params:xml:ns:domain-1.0') do
        xml.tag!('domain:name', @domain.name)
        xml.tag!('domain:trStatus', 'serverApproved')
        xml.tag!('domain:reID', current_epp_user.username)
        xml.tag!('domain:reDate', @domain.transfer_requested_at)
        xml.tag!('domain:acID', current_epp_user.username)
        xml.tag!('domain:acDate', @domain.transferred_at)
        xml.tag!('domain:exDate', @domain.valid_to)
      end
    end
  end

  xml << render('/epp/shared/trID')
end
