xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    xml.tag!('msgQ', 'count' => current_api_user.queued_messages.count, 'id' => @message.id)

    xml << render('/epp/shared/trID')
  end
end
