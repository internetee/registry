xml.epp_head do
  xml.response do
    xml.result('code' => '1301') do
      xml.msg 'Command completed successfully; ack to dequeue'
    end

    xml.tag!('msgQ', 'count' => current_api_user.queued_messages.count, 'id' => @message.id) do
      xml.qDate @message.created_at
      xml.msg @message.body
    end

    xml.resData do
      if @message.attached_obj_type == 'DomainTransfer'
        xml << render('epp/domains/partials/transfer', builder: xml, dt: @object)
      end
    end if @object

    xml << render('/epp/shared/trID')
  end
end
