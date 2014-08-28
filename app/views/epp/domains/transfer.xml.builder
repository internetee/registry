xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.resData do
      xml.tag!('domain:trnData', 'xmlns:domain' => 'urn:ietf:params:xml:ns:domain-1.0') do
        xml.tag!('domain:name', @domain.name)
        ldt = @domain.domain_transfers.last
        xml.tag!('domain:trStatus', ldt.status)
        xml.tag!('domain:reID', ldt.transfer_to.reg_no)
        xml.tag!('domain:reDate', ldt.transfer_requested_at)
        xml.tag!('domain:acID', ldt.transfer_from.reg_no)
        xml.tag!('domain:acDate', ldt.transferred_at) if ldt.transferred_at
        xml.tag!('domain:exDate', @domain.valid_to)
      end
    end
  end

  xml << render('/epp/shared/trID')
end
