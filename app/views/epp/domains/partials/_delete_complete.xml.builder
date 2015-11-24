builder.tag!('domain:delData', 'xmlns:domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd') do
  builder.tag!('domain:name', bye_bye.object['name'])
  builder.tag!('domain:exDate', bye_bye.created_at)
end
