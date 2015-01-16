class Epp::PollsController < ApplicationController
  include Epp::Common

  def poll
    req_poll if parsed_frame.css('poll').first['op'] == 'req'
    ack_poll if parsed_frame.css('poll').first['op'] == 'ack'
  end

  def req_poll
    @message = current_epp_user.queued_messages.last
    render_epp_response 'epp/poll/poll_no_messages' and return unless @message

    if @message.attached_obj_type && @message.attached_obj_id
      @object = Object.const_get(@message.attached_obj_type).find(@message.attached_obj_id)
    end

    if @message.attached_obj_type == 'Keyrelay'
      render_epp_response 'epp/poll/poll_keyrelay'
    else
      render_epp_response 'epp/poll/poll_req'
    end
  end

  def ack_poll
    @message = current_epp_user.queued_messages.find_by(id: parsed_frame.css('poll').first['msgID'])

    unless @message
      epp_errors << {
        code: '2303',
        msg: I18n.t('message_was_not_found'),
        value: { obj: 'msgID', val: parsed_frame.css('poll').first['msgID'] }
      }
      handle_errors and return
    end

    handle_errors(@message) and return unless @message.dequeue
    render_epp_response 'epp/poll/poll_ack'
  end

  private

  def validate_poll
    op = parsed_frame.css('poll').first[:op]
    return true if %w(ack req).include?(op)
    epp_errors << { code: '2306', msg: I18n.t('errors.messages.attribute_op_is_invalid') }
    false
  end
end
