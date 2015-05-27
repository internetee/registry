builder.tag!('domain:trnData', 'xmlns:domain' => 'urn:ietf:params:xml:ns:domain-1.0') do
  builder.tag!('domain:name', dt.domain_name)
  builder.tag!('domain:trStatus', dt.status)
  builder.tag!('domain:reID', dt.transfer_to.code)
  builder.tag!('domain:reDate', dt.transfer_requested_at.try(:iso8601))
  builder.tag!('domain:acID', dt.transfer_from.code)
  builder.tag!('domain:acDate', dt.transferred_at.try(:iso8601) || dt.wait_until.try(:iso8601))
  builder.tag!('domain:exDate', dt.domain_valid_to.try(:iso8601))
end
