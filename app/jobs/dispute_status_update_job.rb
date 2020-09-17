class DisputeStatusUpdateJob < ApplicationJob
  queue_as :default

  def perform(logger: Logger.new(STDOUT))
    @logger = logger

    @backlog = { 'activated': 0, 'closed': 0, 'activate_fail': [], 'close_fail': [] }
               .with_indifferent_access

    close_disputes
    activate_disputes

    @logger.info "DisputeStatusUpdateJob - All done. Closed #{@backlog['closed']} and " \
    "activated #{@backlog['activated']} disputes."

    show_failed_disputes unless @backlog['activate_fail'].empty? && @backlog['close_fail'].empty?
  end

  def close_disputes
    disputes = Dispute.where(closed: nil).where('expires_at < ?', Time.zone.today).all
    @logger.info "DisputeStatusUpdateJob - Found #{disputes.count} closable disputes"
    disputes.each do |dispute|
      process_dispute(dispute, closing: true)
    end
  end

  def activate_disputes
    disputes = Dispute.where(closed: nil, starts_at: Time.zone.today).all
    @logger.info "DisputeStatusUpdateJob - Found #{disputes.count} activatable disputes"

    disputes.each do |dispute|
      process_dispute(dispute, closing: false)
    end
  end

  def process_dispute(dispute, closing: false)
    intent = closing ? 'close' : 'activate'
    success = closing ? dispute.close(initiator: 'Job') : dispute.generate_data
    create_backlog_entry(dispute: dispute, intent: intent, successful: success)
  end

  def create_backlog_entry(dispute:, intent:, successful:)
    if successful
      @backlog["#{intent}d"] += 1
      @logger.info "DisputeStatusUpdateJob - #{intent}d dispute " \
      " for '#{dispute.domain_name}'"
    else
      @backlog["#{intent}_fail"] << dispute.id
      @logger.info 'DisputeStatusUpdateJob - Failed to' \
      "#{intent} dispute for '#{dispute.domain_name}'"
    end
  end

  def show_failed_disputes
    if @backlog['close_fail'].any?
      @logger.info('DisputeStatusUpdateJob - Failed to close disputes with Ids:' \
      "#{@backlog['close_fail']}")
    end

    return unless @backlog['activate_fail'].any?

    @logger.info('DisputeStatusUpdateJob - Failed to activate disputes with Ids:' \
    "#{@backlog['activate_fail']}")
  end
end
