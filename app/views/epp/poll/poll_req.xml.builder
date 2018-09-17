xml.epp_head do
  xml.response do
    xml.result('code' => '1301') do
      xml.msg 'Command completed successfully; ack to dequeue'
    end

    xml.tag!('msgQ', 'count' => current_user.queued_messages.count, 'id' => @message.id) do
      xml.qDate @message.created_at.utc.xmlschema
      xml.msg @message.body
    end

    if @message.attached_obj_type == 'DomainTransfer'
      xml.resData do
        xml << render('epp/domains/partials/transfer', builder: xml, dt: @object)
      end if @object
    end
    render('epp/shared/trID', builder: xml)
  end
end
