xml.epp_head do
  xml.response do
    xml.result('code' => '1301') do
      xml.msg 'Command completed successfully; ack to dequeue'
    end

    xml.tag!('msgQ', 'count' => current_user.unread_notifications.count, 'id' => @notification.id) do
      xml.qDate @notification.created_at.utc.xmlschema
      xml.msg @notification.text
    end

    if @object
      case @notification.attached_obj_type
      when 'DomainTransfer'
        xml.resData do
          xml << render('epp/domains/partials/transfer', builder: xml, dt: @object)
        end
      when 'ContactUpdateAction'
        xml.resData do
          xml << render(
            'epp/contacts/partials/check',
            builder: xml,
            results: @object.to_non_available_contact_codes
          )
        end
      end
    end

    if @notification.attached_obj_type == 'DomainAutoRenewal' && @object && @notification.event &&
       epp_session.extension?(EppSession::AUTO_RENEW_URI)
      xml.extension do
        xml.tag!('autoRenew:pollData', 'xmlns:autoRenew' => EppSession::AUTO_RENEW_URI,
                                     'event' => @notification.event) do
          xml.tag!('autoRenew:name', @object.domain_name)
          render('epp/domains/partials/auto_renew_cycle', builder: xml, cycle: @object)
        end
      end
    elsif @notification.action || @notification.registry_lock?
      if @notification.registry_lock?
        state = @notification.text.include?('unlocked') ? 'unlock' : 'lock'
        render(partial: 'epp/poll/extension',
               locals: { builder: xml,
                         obj: state,
                         type: 'state' })
      else
        render(partial: 'epp/poll/extension',
               locals: { builder: xml,
                         obj: @notification.action,
                         type: 'action' })
      end
    end

    render('epp/shared/trID', builder: xml)
  end
end
