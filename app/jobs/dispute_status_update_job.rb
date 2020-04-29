class DisputeStatusUpdateJob < Que::Job
  def run
    @backlog = { activated: 0, closed: 0, active_fail: [], close_fail: [] }

    close_disputes
    activate_disputes

    Rails.logger.info "DisputeStatusCloseJob - All done. Closed #{@backlog[:closed]} and " \
    "activated #{@backlog[:closed]} disputes."

    show_failed_disputes unless @backlog[:active_fail].empty? && @backlog[:close_fail].empty?
  end

  def close_disputes
    disputes = Dispute.where(closed: false).where('expires_at < ?', Date.today).all
    Rails.logger.info "DisputeStatusCloseJob - Found #{disputes.count} closable disputes"
    disputes.each do |dispute|
      puts "attempnt"
      close_dispute(dispute)
    end
  end

  def activate_disputes
    disputes = Dispute.where(closed: false, starts_at: Date.today).all
    Rails.logger.info "DisputeStatusCloseJob - Found #{disputes.count} activatable disputes"

    disputes.each do |dispute|
      activate_dispute(dispute)
    end
  end

  def close_dispute(dispute)
    if dispute.close
      Rails.logger.info 'DisputeStatusCloseJob - Closed dispute ' \
      "##{dispute.id} for '#{dispute.domain_name}'"
      @backlog[:closed] += 1
    else
      Rails.logger.info 'DisputeStatusCloseJob - Failed to close dispute ' \
      "##{dispute.id} for '#{dispute.domain_name}'"
      @backlog[:close_fail] << dispute.id
    end
  end

  def activate_dispute(dispute)
    if dispute.generate_data
      Rails.logger.info 'DisputeStatusCloseJob - Activated dispute ' \
      "##{dispute.id} for '#{dispute.domain_name}'"
      @backlog[:activated] += 1
    else
      Rails.logger.info 'DisputeStatusCloseJob - Failed to activate dispute ' \
      "##{dispute.id} for '#{dispute.domain_name}'"
      @backlog[:active_fail] << dispute.id
    end
  end

  def show_failed_disputes
    if @backlog[:close_fail].any?
      Rails.logger.info('DisputeStatuseCloseJob - Failed to close disputes with Ids:' \
      "#{@backlog[:close_fail]}")
    end

    return unless @backlog[:active_fail].any?

    Rails.logger.info('DisputeStatuseCloseJob - Failed to activate disputes with Ids:' \
    "#{@backlog[:active_fail]}")
  end
end
