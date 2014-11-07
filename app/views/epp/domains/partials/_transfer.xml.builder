builder.tag!('domain:trnData', 'xmlns:domain' => 'urn:ietf:params:xml:ns:domain-1.0') do
  builder.tag!('domain:name', dt.domain_name)
  builder.tag!('domain:trStatus', dt.status)
  builder.tag!('domain:reID', dt.transfer_to.reg_no)
  builder.tag!('domain:reDate', dt.transfer_requested_at)
  builder.tag!('domain:acID', dt.transfer_from.reg_no)
  builder.tag!('domain:acDate', dt.transferred_at || dt.wait_until)
  builder.tag!('domain:exDate', dt.domain_valid_to)
end
