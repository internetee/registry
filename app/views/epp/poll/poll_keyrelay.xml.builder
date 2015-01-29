xml.instruct!(:xml, standalone: 'no')
xml.epp(
  'xmlns' => 'urn:ietf:params:xml:ns:epp-1.0',
  'xmlns:secDNS' => 'urn:ietf:params:xml:ns:secDNS-1.1',
  'xmlns:domain' => 'urn:ietf:params:xml:ns:domain-1.0',
  'xmlns:keyrelay' => 'urn:ietf:params:xml:ns:keyrelay-1.0'
) do
  xml.response do
    xml.result('code' => '1301') do
      xml.msg 'Command completed successfully; ack to dequeue'
    end

    xml.tag!('msgQ', 'count' => current_api_user.queued_messages.count, 'id' => @message.id) do
      xml.qDate @message.created_at
      xml.msg @message.body
    end

    xml.resData do
      xml.tag!('keyrelay:response') do
        xml.tag!('keyrelay:panData') do
          xml.tag!('keyrelay:name', @object.domain_name)
          xml.tag!('keyrelay:paDate', @object.pa_date)

          xml.tag!('keyrelay:keyData') do
            xml.tag!('secDNS:flags',  @object.key_data_flags)
            xml.tag!('secDNS:protocol',  @object.key_data_protocol)
            xml.tag!('secDNS:alg',  @object.key_data_alg)
            xml.tag!('secDNS:pubKey',  @object.key_data_public_key)
          end


          xml.tag!('keyrelay:authInfo') do
            xml.tag!('domain:pw',  @object.auth_info_pw)
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

    xml << render('/epp/shared/trID')
  end
end
