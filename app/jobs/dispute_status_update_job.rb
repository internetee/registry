class DisputeStatusUpdateJob < ApplicationJob
  def perform(logger: Logger.new($stdout), include_closed: false)
    @logger = logger
    @include_closed = include_closed

    @backlog = { 'activated': 0, 'closed': 0, 'activate_fail': [], 'close_fail': [] }
               .with_indifferent_access

    close_disputes
    activate_disputes
    clean_disputed

    @logger.info "DisputeStatusUpdateJob - All done. Closed #{@backlog['closed']} and " \
    "activated #{@backlog['activated']} disputes."

    show_failed_disputes unless @backlog['activate_fail'].empty? && @backlog['close_fail'].empty?
  end

  def clean_disputed
    domains = Domain.where("array_to_string(statuses, '||') ILIKE ?", '%disputed%')
    domains.each do |domain|
      unless domain.disputed?
        domain.unmark_as_disputed 
        @logger.info "DisputeStatusUpdateJob - Found domain #{domain.name} with disputed status. But disputed record already closed. Unmarking dispute status"
      end
    end
  end

  def close_disputes
    disputes = if @include_closed
                 Dispute.where('expires_at < ?', Time.zone.today).all
               else
                 Dispute.where(closed: nil).where('expires_at < ?', Time.zone.today).all
               end
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
