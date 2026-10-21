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

    if @auto_renew_requested && epp_session.extension?(EppSession::AUTO_RENEW_URI)
      xml.extension do
        xml.tag!('autoRenew:creData', 'xmlns:autoRenew' => EppSession::AUTO_RENEW_URI) do
          xml.tag!('autoRenew:enabled', @domain.auto_renew.to_s)
        end
      end
    end

    render('epp/shared/trID', builder: xml)
  end
end
