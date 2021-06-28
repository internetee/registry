xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.resData do
      xml.tag!('domain:creData',
               'xmlns:domain' => Xsd::Schema.filename(for_prefix: @schema_prefix,
                                                      for_version: @schema_version)) do
        xml.tag!('domain:name', @domain.name)
        xml.tag!('domain:crDate', @domain.created_at.try(:iso8601))
        xml.tag!('domain:exDate', @domain.valid_to.iso8601)
      end
    end

    render('epp/shared/trID', builder: xml)
  end
end
