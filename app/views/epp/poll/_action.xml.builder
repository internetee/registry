builder.extension do
  builder.tag!('changePoll:changeData',
               'xmlns:changePoll' => Xsd::Schema.filename(for_prefix: 'changePoll', for_version: '1.0')) do
    builder.tag!('changePoll:operation', action.operation)
    builder.tag!('changePoll:date', action.created_at.utc.xmlschema)
    builder.tag!('changePoll:svTRID', action.id)
    builder.tag!('changePoll:who', action.user)
    if action.bulk_action?
      builder.tag!('changePoll:reason', 'Auto-update according to official data')
    end
  end
end
