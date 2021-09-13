xml.epp_head do
  xml.response do
    xml.result('code' => '1301') do
      xml.msg 'Command completed successfully; ack to dequeue'
    end

    xml.tag!('msgQ', 'count' => current_user.unread_notifications.count, 'id' => @notification.id) do
      xml.qDate @notification.created_at.utc.xmlschema
      xml.msg @notification.text
    end

    if @notification.attached_obj_type == 'DomainTransfer' && @object
      xml.resData do
        xml << render('epp/domains/partials/transfer', builder: xml, dt: @object)
      end
    end

    if @notification.action&.contact || @notification.registry_lock?
      if @notification.registry_lock?
        state = @notification.text.include?('unlocked') ? 'unlock' : 'lock'
        xml.extension do
          xml.tag!('changePoll:changeData',
                   'xmlns:changePoll': Xsd::Schema.filename(for_prefix: 'changePoll')) do
            xml.tag!('changePoll:operation', state)
          end
        end
      else
        render(partial: 'epp/poll/action',
               locals: {
                 builder: xml,
                 action: @notification.action,
               })
      end
    end

    render('epp/shared/trID', builder: xml)
  end
end
