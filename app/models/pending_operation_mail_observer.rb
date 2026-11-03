class PendingOperationMailObserver
  def self.delivered_email(message)
    id = message['X-Pending-Operation-ID']&.value
    return if id.blank?

    started = PendingOperationEvent.find_by(pending_operation_id: id, event: 'started')
    return unless started

    domain = Domain.find_by(id: started.domain_id)
    return unless domain

    Array(message.to).each do |recipient|
      PendingOperationEvent.record(domain: domain, event: 'email_sent', operation_id: id,
                                   operation: started.operation, recipient_email: recipient,
                                   actor: { type: 'system' })
    end
  rescue StandardError => e
    Rails.logger.warn("Pending operation email audit failed: #{e.class}: #{e.message}")
  end
end
