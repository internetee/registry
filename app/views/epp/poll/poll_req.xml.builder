xml.epp_head do
  xml.response do
    xml.result('code' => '1301') do
      xml.msg 'Command completed successfully; ack to dequeue'
    end

    xml.tag!('msgQ', 'count' => current_user.queued_messages.count, 'id' => @message.id) do
      xml.qDate @message.created_at.try(:iso8601)
      xml.msg @message.body
    end

    xml.resData do
      case @message.attached_obj_type
        when 'DomainTransfer'
          xml << render('epp/domains/partials/transfer', builder: xml, dt: @object)
      end
    end if @object

    render('epp/shared/trID', builder: xml)
  end
end
