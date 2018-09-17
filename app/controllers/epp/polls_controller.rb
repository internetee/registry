class Epp::PollsController < EppController
  skip_authorization_check # TODO: move authorization under ability

  def poll
    req_poll if params[:parsed_frame].css('poll').first['op'] == 'req'
    ack_poll if params[:parsed_frame].css('poll').first['op'] == 'ack'
  end

  private

  def req_poll
    @message = current_user.queued_messages.order('created_at DESC').take

    render_epp_response 'epp/poll/poll_no_messages' and return unless @message
    if @message.attached_obj_type && @message.attached_obj_id
      begin
        @object = Object.const_get(@message.attached_obj_type).find(@message.attached_obj_id)
      rescue => problem
        # the data model might be inconsistent; or ...
        # this could happen if the registrar does not dequeue messages, and then the domain was deleted

        # SELECT messages.id, domains.name, messages.body FROM messages LEFT OUTER
        # JOIN domains ON attached_obj_id::INTEGER = domains.id
        # WHERE attached_obj_type = 'Epp::Domain' AND name IS NULL;

        Rails.logger.error 'orphan message, error ignored: ' + problem.to_s
        # now we should dequeue or delete the messages avoid duplicate log alarms
      end
    end

    if @message.attached_obj_type == 'Keyrelay'
      render_epp_response 'epp/poll/poll_keyrelay'
    else
      render_epp_response 'epp/poll/poll_req'
    end
  end

  def ack_poll
    @message = current_user.queued_messages.find_by(id: params[:parsed_frame].css('poll').first['msgID'])

    unless @message
      epp_errors << {
        code: '2303',
        msg: I18n.t('message_was_not_found'),
        value: { obj: 'msgID', val: params[:parsed_frame].css('poll').first['msgID'] }
      }
      handle_errors and return
    end

    handle_errors(@message) and return unless @message.dequeue
    render_epp_response 'epp/poll/poll_ack'
  end

  def validate_poll
    requires_attribute 'poll', 'op', values: %(ack req), allow_blank: true
  end

  def resource
    @message
  end
end
