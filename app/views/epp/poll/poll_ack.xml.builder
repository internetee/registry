xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.tag!('msgQ', 'count' => current_user.unread_notifications.count, 'id' => @notification.id)

    render('epp/shared/trID', builder: xml)
  end
end
