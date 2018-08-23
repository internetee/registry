xml.epp_head do
  xml.response do
    xml.result('code' => '1301') do
      xml.msg 'Command completed successfully; ack to dequeue'
    end

    xml.tag!('msgQ', 'count' => current_user.queued_notifications.count, 'id' => @notification.id) do
      xml.qDate @notification.created_at.try(:iso8601)
      xml.msg @notification.body
    end

    if @notification.attached_obj_type == 'DomainTransfer'
      xml.resData do
        xml << render('epp/domains/partials/transfer', builder: xml, dt: @object)
      end if @object
    end
    render('epp/shared/trID', builder: xml)
  end
end
