builder.extension do
  builder.tag!('changePoll:changeData',
               'xmlns:changePoll' => Xsd::Schema.filename(for_prefix: 'changePoll',
                                                          for_version: '1.0')) do
    case type
    when 'action'
      builder.tag!('changePoll:operation', obj.operation)
      builder.tag!('changePoll:date', obj.created_at.utc.xmlschema)
      builder.tag!('changePoll:svTRID', obj.id)
      builder.tag!('changePoll:who', obj.user)
      builder.tag!(
        'changePoll:reason',
        'Auto-update according to official data'
      ) if obj.bulk_action?
    when 'state'
      builder.tag!('changePoll:operation', obj)
    end
  end
end
