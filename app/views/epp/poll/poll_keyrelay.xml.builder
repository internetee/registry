xml.instruct!(:xml, standalone: 'no')
xml.epp(
  'xmlns' => 'https://epp.tld.ee/schema/epp-ee-1.0.xsd',
  'xmlns:secDNS' => 'urn:ietf:params:xml:ns:secDNS-1.1',
  'xmlns:domain' => 'https://epp.tld.ee/schema/domain-eis-1.0.xsd',
  'xmlns:keyrelay' => 'urn:ietf:params:xml:ns:keyrelay-1.0'
) do
  xml.response do
    xml.result('code' => '1301') do
      xml.msg 'Command completed successfully; ack to dequeue'
    end

    xml.tag!('msgQ', 'count' => current_user.unread_notifications.count, 'id' => @notification.id) do
      xml.qDate @notification.created_at.try(:iso8601)
      xml.msg @notification.text
    end

    xml.resData do
      xml.tag!('keyrelay:response') do
        xml.tag!('keyrelay:panData') do
          xml.tag!('keyrelay:name', @object.domain_name)
          xml.tag!('keyrelay:paDate', @object.pa_date.try(:iso8601))

          xml.tag!('keyrelay:keyData') do
            xml.tag!('secDNS:flags', @object.key_data_flags)
            xml.tag!('secDNS:protocol', @object.key_data_protocol)
            xml.tag!('secDNS:alg', @object.key_data_alg)
            xml.tag!('secDNS:pubKey', @object.key_data_public_key)
          end

          xml.tag!('keyrelay:authInfo') do
            xml.tag!('domain:pw', @object.auth_info_pw)
          end

          xml.tag!('keyrelay:expiry') do
            xml.tag!('keyrelay:relative',  @object.expiry_relative)
            xml.tag!('keyrelay:absolute',  @object.expiry_absolute)
          end

          xml.tag!('keyrelay:reID', @object.requester)
          xml.tag!('keyrelay:acID', @object.accepter)
        end
      end
    end

    render('epp/shared/trID', builder: xml)
  end
end
