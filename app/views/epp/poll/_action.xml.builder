builder.extension do
  builder.tag!('changePoll:changeData',
               'xmlns:changePoll' => 'https://epp.tld.ee/schema/changePoll-1.0.xsd') do
    builder.tag!('changePoll:operation', action.operation)
    builder.tag!('changePoll:date', action.created_at.utc.xmlschema)
    builder.tag!('changePoll:svTRID', action.id)
    builder.tag!('changePoll:who', action.user)
  end
end