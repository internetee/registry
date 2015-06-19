xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.tag!('msgQ', 'count' => current_user.queued_messages.count, 'id' => @message.id)

    render('epp/shared/trID', builder: xml)
  end
end
